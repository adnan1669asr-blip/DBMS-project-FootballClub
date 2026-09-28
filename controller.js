const express = require("express");
const { 
	testOracleConnection,
	getAllNamePositionTeam,
	getTeams,
	getPositions,
	insertAthlete,
	deleteAthlete,
	getAthlete,
	updateAthlete,
	getPlayerAwards,
	getTables,
	getAttributes,
	getTable,
	getStandings,
	getMaxAvgGoalsPerGame,
	getFourMostRecentGames,
	getTeamsByCoachExp,
	getRefsInAllGames,
	findPhoneNumber,
	findEmail,
	getVenues,
	findGames,
	filterSponsor
} = require("./dbQueries");

const router = express.Router();

const queryToJson = require("./utils/helpers");

router.get("/check-db-connection", async (req, res) => {
    const isConnect = await testOracleConnection();
    if (isConnect) {
        res.send("Connected!");
    } else {
        res.send("Unable to connect!");
    }
});

router.get("/name-position-team", async (req, res) => {
	let result = await getAllNamePositionTeam();
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
	
});

router.get("/teams", async (req, res) => {
	let result = await getTeams();
	if (result) {
		res.status(200).json(queryToJson(result));	
	} else {
		res.status(404).send("Not found"); 
	}
	
});

router.get("/positions", async (req, res) => {
	let result = await getPositions();
	if (result) {
		res.status(200).json(queryToJson(result));	
	} else {
		res.status(404).send("Not found"); 
	}
	
});

router.get("/athlete/:person_id", async (req, res) => {
	let result = await getAthlete(req.params.person_id);
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.post("/athlete", async (req, res) => {
	let result = await insertAthlete(req.body);
	if (result) {
		res.json({ success: true });
	} else {
		res.status(500).json({ success: false });
	}
});

router.delete("/athlete/:person_id", async (req, res) => {
	let result = await deleteAthlete(req.params.person_id);
    if (result) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.put("/athlete", async (req, res) => {
	let result = await updateAthlete(req.body);
	if (result) {
		res.json({ success: true });
	} else {
		res.status(500).json({ success: false });
	}
});

router.get("/awards/athlete/:person_id", async (req, res) => {
	let result = await getPlayerAwards(req.params.person_id);
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}	
});


router.get("/tables", async (req, res) => {	
	let result = await getTables();
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.get("/table/:table_name/attributes", async (req, res) => {	
	let result = await getAttributes(req.params.table_name);
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.post("/table", async (req, res) => {	
	let result = await getTable(req.body);
	if (result) {
		res.status(200).json(queryToJson(result));	
	} else {
		res.status(404).send("Not found");
	}
});

router.get("/standings", async (req, res) => {	
	let result = await getStandings();
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.get("/max-avg-goals-per-game", async (req, res) => {	
	let result = await getMaxAvgGoalsPerGame();
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.get("/recent-games", async (req, res) => {
	let result = await getFourMostRecentGames(req.query.limit || null);
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.get("/teams-by-coach-exp", async (req, res) => {	
	let result = await getTeamsByCoachExp();
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.get("/refs-in-all-games", async (req, res) => {	
	let result = await getRefsInAllGames();
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.post("/phone-exists", async (req, res) => {
	let result = await findPhoneNumber(req.body);
	if (result.rows.length !== 0) {
		res.status(200).json({ exists: true });
	} else {
		res.status(200).json({ exists: false });
	}
});

router.post("/email-exists", async (req, res) => {
	let result = await findEmail(req.body);
	if (result.rows.length !== 0) {
		res.status(200).json({ exists: true });
	} else {
		res.status(200).json({ exists: false });
	}
});

router.get("/venues", async (req, res) => {	
	let result = await getVenues();
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.post("/find-games", async (req, res) => {
	let result = await findGames(req.body);
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});

router.post("/filter-sponsor", async (req, res) => {
	let result = await filterSponsor(req.body);
	if (result) {
		res.status(200).json(queryToJson(result));
	} else {
		res.status(404).send("Not found");
	}
});


module.exports = router;