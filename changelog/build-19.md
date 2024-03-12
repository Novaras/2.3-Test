# Build 19

Includes:
- https://github.com/Novaras/2.3-Test/pull/9
- https://github.com/Novaras/2.3-Test/pull/10
- https://github.com/Novaras/2.3-Test/pull/11
- https://github.com/Novaras/2.3-Test/pull/12
- https://github.com/Novaras/2.3-Test/pull/13
- https://github.com/Novaras/2.3-Test/pull/14
- https://github.com/Novaras/2.3-Test/pull/15

TLDR for emp changes:

| Race | Fighters\*                                   | Corvettes                  | Frigate                             | Burst Radius   | # Hits to Stun Fighters | # Hits to Stun Vettes | # Hits to Stun Frigates\*\* |
|------|----------------------------------------------|----------------------------|-------------------------------------|----------------|-------------------------|-----------------------|-----------------------------|
| Hgn  | HP: `110` -> `200`, regen time: `20` -> `16` | HP: `110` regen time: `20` | HP: `310` -> `300` regen time: `20` | `500` -> `480` | 5 Hits -> 7 Hits        | 5 Hits                | 11 Hits -> 10 Hits          |
| Vgr  | HP: `110` -> `200`, regen time: `20` -> `16` | HP: `110` regen time: `20` | HP: `310` -> `300` regen time: `20` | `500` -> `480` | 5 Hits -> 7 Hits        | 5 Hits                | 11 Hits -> 10 Hits          |

\*: Scouts have `200` HP, taking 7 hits to stun
\*\*: The Hgn Defense Field Frigate only has `270` HP, taking only 9 hits to stun