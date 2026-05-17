const express = require('express');
const router = express.Router();
const projectController = require('../controllers/projectController');

-
router.get('/', projectController.getAllProjects);
router.post('/', projectController.createProject);
router.delete('/:id', projectController.deleteProject);


router.get('/:projectId/members', projectController.getProjectMembers);
router.post('/members', projectController.addProjectMember);
router.delete('/:projectId/members/:userId', projectController.removeProjectMember);


router.patch('/:projectId/finalize', projectController.finalizeProject);
router.get('/:projectId/available-users', projectController.getAvailableUsers);

module.exports = router;
