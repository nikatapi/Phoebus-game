class_name Zodiac
extends RefCounted
## Static data for the twelve signs: element, world, and the power each grants.

const SIGNS := {
	"aries":       {"name": "Aries",       "element": "fire",  "power": "Ram Dash",      "desc": "Burst forward and smash cracked walls."},
	"leo":         {"name": "Leo",         "element": "fire",  "power": "Roar",          "desc": "Stun nearby enemies."},
	"sagittarius": {"name": "Sagittarius", "element": "fire",  "power": "Arrow Shot",    "desc": "Fire an arrow; hits switches at range."},
	"taurus":      {"name": "Taurus",      "element": "earth", "power": "Ground Pound",  "desc": "Slam down through weak floors."},
	"virgo":       {"name": "Virgo",       "element": "earth", "power": "Reveal",        "desc": "Show hidden platforms for a few seconds."},
	"capricorn":   {"name": "Capricorn",   "element": "earth", "power": "Wall Climb",    "desc": "Cling to and climb rough walls."},
	"gemini":      {"name": "Gemini",      "element": "air",   "power": "Twin Decoy",    "desc": "Leave a clone that draws enemy attention."},
	"libra":       {"name": "Libra",       "element": "air",   "power": "Scale Swap",    "desc": "Swap places with a marked object."},
	"aquarius":    {"name": "Aquarius",    "element": "air",   "power": "Frost Pour",    "desc": "Pour water that freezes into a platform."},
	"cancer":      {"name": "Cancer",      "element": "water", "power": "Shell Guard",   "desc": "Block one hit; reflect projectiles."},
	"scorpio":     {"name": "Scorpio",     "element": "water", "power": "Stinger Hook",  "desc": "Grapple to hook points."},
	"pisces":      {"name": "Pisces",      "element": "water", "power": "Deep Dive",     "desc": "Swim freely underwater."},
}

## Start date (month, day) of each sign, in calendar order.
const STARTS := [
	[1, 20, "aquarius"], [2, 19, "pisces"], [3, 21, "aries"], [4, 20, "taurus"],
	[5, 21, "gemini"], [6, 21, "cancer"], [7, 23, "leo"], [8, 23, "virgo"],
	[9, 23, "libra"], [10, 23, "scorpio"], [11, 22, "sagittarius"], [12, 22, "capricorn"],
]

static func sign_for_date(month: int, day: int) -> String:
	var result := "capricorn" # Jan 1 to Jan 19
	for s in STARTS:
		if month > s[0] or (month == s[0] and day >= s[1]):
			result = s[2]
	return result

static func current_season() -> String:
	var d := Time.get_date_dict_from_system()
	return sign_for_date(d["month"], d["day"])

static func display_name(id: String) -> String:
	return SIGNS[id]["name"] if SIGNS.has(id) else "-"
