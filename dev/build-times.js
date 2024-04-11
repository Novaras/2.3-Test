import * as fs from 'node:fs/promises';
import * as readline from 'node:readline/promises';
import { glob } from 'glob';
import * as cli_prog from 'cli-progress';

/** @type { { [key: string]: string } } */
const data = {};

const files = await glob('../{ship,subsystem}/**/*.{ship,subs}');

const progress_bar = new cli_prog.SingleBar({
	format: `Reading ${files.length} ship files: [{bar}] {percentage}% | {value}/{total} (ETA: {eta}s)`,
	clearOnComplete: false,
}, cli_prog.Presets.rect);

const RACE_PREFIX_MAP = Object.freeze({
	'hgn': 'hiigaran',
	'vgr': 'vaygr',
	'kus': 'kushan',
	'tai': 'taiidan',
});
// in the scope of `def_build` (which uses the data we generate here), Lua's `strlower` is not in scope, so
// the capitalisation of these keys is critical
// because of that we will look up the name from `def_build` here (where we have the future technology of casting a string to
// lowercase), and save that as the key
// these readers are used for that, one for each `def_build` file

/**
 * @type { { [key: string]: { time: number, description: string } } }
 */
const races_def_build_contents = (await Promise.all(
	Object.entries(RACE_PREFIX_MAP)
		.map(async ([prefix, fullname]) => {
			const data = (await fs.readFile(`../scripts/races/${fullname}/scripts/def_build.lua`)).toString();
			return [prefix, data];
		})
)).reduce((out_obj, [prefix, file_contents]) => {
	return {
		...out_obj,
		[prefix]: file_contents
	};
}, {});

console.log(`Parsing .dat files...`);

const datfiles = ['buildresearch', 'hw1buildresearch', 'ships', 'hw1ships', 'ati', 'events'];

const datfile_data = (await Promise.all(
	datfiles.map((filename) => fs.readFile(`../${filename}.dat`))
)).reduce((data, buffer) => {
	const lines = buffer.toString().split(`\n`);

	for (const line of lines) {
		const [key, text] = line.split(/\t(.*)/s);

		data[key] = text;
	}

	return data;
}, {});

const locale_lua_tbl_str = Object.entries(datfile_data).reduce((tbl_str, [key, text]) => {
		if (key && text) {
			const parsed = text.slice(0, -1).replaceAll(`"`, `\\"`);

			return tbl_str.concat(`\t["$${key}"] = "${parsed}",\n`);
		}

		return tbl_str;
	}, '');
const locale_lua_str = `-- Locale data from '.dat' files, as a Lua table
-- generated by 'dev/build-times.js'

localization = {\n${locale_lua_tbl_str}};
`;
console.log(`Done, writing to localeenglish.lua...`);
await fs.writeFile(`../scripts/productiontimes/localeenglish.lua`, locale_lua_str);

progress_bar.start(files.length, 0);
for (const file of files) {
	progress_bar.increment(1);

	// ship type is the last part of splitting the path, then split that last part on the file extension dot
	const ship_type = file.split('\\').reverse()[0].split('.')[0];

	const race_prefix = ship_type.split('_')[0];

	if (!Object.keys(RACE_PREFIX_MAP).includes(race_prefix)) {
		continue;
	}

	const ship_type_formatted = (() => {
		const def_build_content = races_def_build_contents[race_prefix];

		const match = def_build_content.match(new RegExp(ship_type, 'i'));
		if (match) return match[0];
	})();

	if (!ship_type_formatted) {
		continue;
	}

	const src_file_contents = (await fs.readFile(file)).toString();

	for await (const line of src_file_contents.split('\n')) {
		// match like:
		// 'buildTime' followed by anything any number of times,
		// then '=', then anything any number of times,
		// then capture any number of digits (allowing decimals even those missing the leading 0)
		const match = line.match(/(?:buildTime|timeToBuild).*?=.*?[+-]?(\d*\.?\d+)/s);

		// if we matched, the build time is stored in the first capture
		if (match) {
			const build_time = match[1];

			// store it
			data[ship_type_formatted] = build_time;
		}
	}
}

progress_bar.stop();

const lua_tbl_lines = Object.entries(data).reduce((lua_str, [ship_type, build_time]) => {
	return lua_str.concat(`\t["${ship_type}"] = "${build_time}",\n`);
}, '');
const lua_tbl_str = `{\n${lua_tbl_lines}}`;
const lua_str = `-- Build times used by 'applybuildtimes.lua' to display in the UI.
-- generated by 'dev/build-times.js'

buildtimes = ${lua_tbl_str}
`;

const output_path = "../scripts/productiontimes/buildtimes.lua";

console.log(`Writing to ${output_path}...`);
await fs.writeFile(output_path, lua_str);



console.log(`✨ Done ✨`);