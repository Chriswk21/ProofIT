const express = require('express');
const router = express.Router();
const notifController = require('../controllers/notificationController');

router.get('/:userId', notifController.getNotifications);
router.get('/unread-count/:userId', notifController.getUnreadCount);
router.put('/read/:notifId', notifController.markAsRead);
router.post('/mark-read/:userId', notifController.markAllRead);

module.exports = router;