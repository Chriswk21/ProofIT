const express = require('express');
const router = express.Router();
const roadmapController = require('../controllers/roadmapController');


router.get('/', roadmapController.getRoadmapData);

router.post('/task', roadmapController.saveTask);
router.delete('/task/:id', roadmapController.deleteTask);

module.exports = router;