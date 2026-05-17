const express = require('express');
const router = express.Router();
const forumController = require('../controllers/forumController');

router.post('/upload', forumController.uploadMiddleware, forumController.uploadFile);
router.get('/:projectId', forumController.getForumMessages);
router.post('/', forumController.addMessage);
router.put('/:id', forumController.editMessage);
router.delete('/:id', forumController.deleteMessage);

module.exports = router;