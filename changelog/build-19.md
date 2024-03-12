# Build 19

Includes:
- mvettes damage vs collectors: https://github.com/Novaras/2.3-Test/pull/9
- hw1 needs Fighter Drive to build scouts: https://github.com/Novaras/2.3-Test/pull/10
- EMP tweaks (also detailed below): https://github.com/Novaras/2.3-Test/pull/11
- repair vette slight damage nerf: https://github.com/Novaras/2.3-Test/pull/12
- missile corvette missile volume nerf & vgr cruiser tricannon volume buff: https://github.com/Novaras/2.3-Test/pull/13
- more aggressivly try to re-issue dock on slow injured squads: https://github.com/Novaras/2.3-Test/pull/14
- fix scouts having bonus ms due to a formation bonus: https://github.com/Novaras/2.3-Test/pull/15

TLDR for emp changes:

| Race | Fighters\*                                   | Corvettes                  | Frigate                             | Burst Radius   | # Hits to Stun Fighters | # Hits to Stun Vettes | # Hits to Stun Frigates\*\* |
|------|----------------------------------------------|----------------------------|-------------------------------------|----------------|-------------------------|-----------------------|-----------------------------|
| Hgn  | HP: `110` -> `200`, regen time: `20` -> `16` | HP: `110` regen time: `20` | HP: `310` -> `300` regen time: `20` | `500` -> `480` | 5 Hits -> 7 Hits        | 5 Hits                | 11 Hits -> 10 Hits          |
| Vgr  | HP: `110` -> `200`, regen time: `20` -> `16` | HP: `110` regen time: `20` | HP: `310` -> `300` regen time: `20` | `500` -> `480` | 5 Hits -> 7 Hits        | 5 Hits                | 11 Hits -> 10 Hits          |

- \* Scouts have `200` HP, taking 7 hits to stun
- \*\* The Hgn Defense Field Frigate only has `270` HP, taking only 9 hits to stun

Vgr's cooldown also went up from `70s` -> `80s`, and Hgns from `70s` -> `75s`.
