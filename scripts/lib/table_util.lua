--Table utility functions.

if (TBL_UTIL == nil) then
	function tbl_filter(table, predicate)
		local out = {}
		for i, v in table do
			if (predicate(v, i, table)) then
				out[i] = v
			end
		end
		return out
	end

	function tbl_map(table, transform)
		local out = {}
		for i, v in table do
			out[i] = transform(v, i, table)
		end
		return out
	end

	function tbl_reduce(table, accumulator, initial_value)
		local out = initial_value
		for i, v in table do
			out = accumulator(out, v, i, table)
		end
		return out
	end

	function tbl_merge(tbl_a, tbl_b, merger)
		merger = merger or function (a, b)
			if (type(a) == "table" and type(b) == "table") then
				return tbl_merge(a, b);
			else
				return (b or a);
			end
		end
		if (tbl_a == nil and tbl_b ~= nil) then
			return tbl_b
		elseif (tbl_a ~= nil and tbl_b == nil) then
			return tbl_a
		elseif (tbl_b == nil and tbl_b == nil) then
			return {}
		end
		local out = tbl_a
		for k, v in tbl_b do
			if (out[k] == nil) then
				out[k] = v
			else
				out[k] = merger(out[k], tbl_b[k])
			end
		end
		return out
	end

	function tbl_concat(tbl_a, tbl_b)
		local out = tbl_merge({}, tbl_a);
		local len = tbl_length(tbl_a);
		for _, v in tbl_b do
			tbl_push(out, v, len);
			len = len + 1;
		end
		return out;
	end

	function tbl_includesValue(table, value)
		for i, v in table do
			if v == value then
				return true
			end
		end
		return false
	end

	function tbl_includesKey(table, value)
		for i, v in table do
			if i == value then
				return true
			end
		end
		return false
	end

	function tbl_length(table)
		local n = 0;
		for _, _ in table do
			n = n + 1;
		end
		return n;
	end

	function tbl_push(table, value, len)
		len = len or tbl_length(table);
		table[len + 1] = value;
	end

	function tbl_shift(table, value)
		local out = {};
		local first_idx = 1;
		for i, v in table do
			if (first_idx) then
				out[i] = value;
				first_idx = nil;
			end
			out[i + 1] = v;
		end
		return out;
	end

	TBL_UTIL = 1;
end