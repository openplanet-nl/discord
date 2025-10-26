#if !FOREVER

// Please contact Miss on the Openplanet Discord if you would like
// your pack to be added to this list! I periodically add popular
// title packs as well. You may also submit a pull request on Github.
dictionary g_titles = {
#if TMNEXT
	// Next only has 1 titlepack
	{ "Trackmania", "default" }
#elif TURBO
	// Turbo only has 1 titlepack
	{ "TMTurbo@nadeolabs", "title_turbo" }
#else
	// Official Nadeo titlepacks
	{ "TMStadiumChase@nadeolabs",  "title_stadiumchase" },
	{ "SMStormBattle@nadeolabs",   "title_smbattle" },
	{ "SMStormCombo@nadeolabs",    "title_smcombo" },
	{ "SMStormElite@nadeolabs",    "title_smelite" },
	{ "SMStormJoust@nadeolabs",    "title_smjoust" },
	{ "SMStormRoyal@nadeolabs",    "title_smroyal" },
	{ "SMStormSiege@nadeolabs",    "title_smsiege" },
	{ "SMStormWarlords@nadeolabs", "title_smwarlords" },

	// Custom titlepacks by players
	{ "esl_comp@lt_forever",       "title_esl_comp" },
	{ "RPG@tmrpg",                 "title_rpg" },
	{ "obstacle@smokegun",         "title_obstacle" },
	{ "Pursuit@domino54",          "title_pursuit" },
	{ "PursuitStadium@domino54",   "title_pursuitstadium" },
	{ "GalaxyTitles@domino54",     "title_galaxy" },
	{ "Infection@dmark",           "title_infection" },
	{ "TMPlus_Canyon@tipii",       "title_tmplus" },
	{ "Nimble@ansjh",              "title_nimble" },
	{ "SpeedBall@steeffeen",       "title_speedball" },
	{ "TM2UF@adamkooo",            "title_tmuf" },
	{ "TMAll@domino54",            "title_tmall" },
	{ "Endurance@thaumictom",      "title_endurance" },
	{ "Nadeo_Envimix@bigbang1112", "title_nadeoenvimix" },
	{ "Countdown@torrent",         "title_countdown" },
	{ "GEs@guerro",                "title_stormium" },
	{ "Platform@adamkooo",         "title_platform" },

	// TM One has multiple pack owners
	{ "TMOneAlpine@florenzius",    "title_tmonealpine" },
	{ "TMOneSpeed@florenzius",     "title_tmonespeed" },
	{ "TMOneBay@florenzius",       "title_tmonebay" },
	{ "TMOneAlpine@unbitn",        "title_tmonealpine" },
	{ "TMOneSpeed@unbitn",         "title_tmonespeed" },
	{ "TMOneBay@unbitn",           "title_tmonebay" },

	// StarTrack
	{ "StarTrackStadium@arkes910", "title_startrack_stadium" },
	{ "StarTrackValley@arkes910",  "title_startrack_valley" },
	{ "StarTrackLagoon@arkes910",  "title_startrack_lagoon" },
	{ "StarTrackCanyon@arkes910",  "title_startrack_canyon" },

	// Challenge
	{ "Challenge@bigbang1112",                  "title_challenge" },
	{ "Challenge_Stadium@bigbang1112",          "title_challenge_stadium" },
	{ "Challenge_Campaign@bigbang1112",         "title_challenge_campaign" },
	{ "Challenge_Stadium_Campaign@bigbang1112", "title_challenge_stadium_campaign" },
	{ "Challenge_Maker@bigbang1112",            "title_challenge_maker" },
	{ "Challenge_Stadium_Maker@bigbang1112",    "title_challenge_stadium_maker" },

	// Packs in development
	{ "TMOneMassif@unbitn", "title_dev" },
	{ "TMOneIsland@unbitn", "title_dev" },
	{ "TMOneCoast@unbitn",  "title_dev" },
	{ "TMOneRally@unbitn",  "title_dev" }
#endif
};

#endif
