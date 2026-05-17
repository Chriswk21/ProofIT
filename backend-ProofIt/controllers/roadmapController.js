const supabase = require('../supabaseClient');


exports.getRoadmapData = async (req, res) => {
    const { userId, role } = req.query;

    if (!userId) {
        return res.status(400).json({ message: "userId is required" });
    }

    try {
        let projectsData = [];

        if (role === 'Admin') {

            const { data, error } = await supabase
                .from('projects')
                .select('*')
                .eq('created_by', userId);

            if (error) throw error;
            projectsData = data || [];
        } else {

            const { data: memberRows, error: memberError } = await supabase
                .from('project_members')
                .select('project_id')
                .eq('user_id', userId);

            if (memberError) throw memberError;

            const projectIds = (memberRows || []).map(m => m.project_id);

            if (projectIds.length > 0) {
                const { data, error } = await supabase
                    .from('projects')
                    .select('*')
                    .in('id', projectIds);

                if (error) throw error;
                projectsData = data || [];
            }
        }

        // Ambil tasks jika ada proyek yang ditemukan
        let tasksData = [];
        if (projectsData.length > 0) {
            const projectIds = projectsData.map(p => p.id);
            const { data, error } = await supabase
                .from('tasks')
                .select('*')
                .in('project_id', projectIds)
                .order('end_date', { ascending: true });

            if (error) throw error;

            tasksData = (data || []).filter(t => t.start_date && t.end_date);
        }

        res.status(200).json({
            projects: projectsData,
            tasks: tasksData
        });
    } catch (err) {
        console.error('[Roadmap] getRoadmapData error:', err.message);
        res.status(500).json({ message: "Server Error", error: err.message });
    }
};



exports.saveTask = async (req, res) => {
    try {
        const task = req.body;

        if (!task.project_id || !task.title) {
            return res.status(400).json({ message: "Project ID and Title are required" });
        }

        let data, error;

        if (task.id) {

            ({ data, error } = await supabase
                .from('tasks')
                .upsert(task)
                .select());
        } else {

            const { id, ...taskWithoutId } = task;
            ({ data, error } = await supabase
                .from('tasks')
                .insert([taskWithoutId])
                .select());
        }

        if (error) throw error;
        res.status(201).json({
            message: "Task saved successfully",
            data: data[0]
        });
    } catch (err) {
        console.error('[Roadmap] saveTask error:', err.message);
        res.status(400).json({ message: "Failed to save task", error: err.message });
    }
};

// DELETE task
exports.deleteTask = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await supabase
            .from('tasks')
            .delete()
            .eq('id', id);

        if (error) throw error;
        res.status(200).json({ message: "Task deleted successfully" });
    } catch (err) {
        res.status(400).json({ message: "Failed to delete task", error: err.message });
    }
};