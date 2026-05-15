const supabase = require('../supabaseClient');

// Ambil semua proyek
exports.getAllProjects = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Tambah proyek baru
exports.createProject = async (req, res) => {
  try {
    const { title, description, status, location, start_date, end_date } = req.body;
    const { data, error } = await supabase
      .from('projects')
      .insert([{ title, description, status, location, start_date, end_date }])
      .select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Hapus proyek
exports.deleteProject = async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase
      .from('projects')
      .delete()
      .eq('id', id);

    if (error) throw error;
    res.status(200).json({ message: "Project deleted successfully" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Ambil daftar anggota tim dari projectId
exports.getProjectMembers = async (req, res) => {
  try {
    const { projectId } = req.params;
    const { data, error } = await supabase
      .from('project_members')
      .select('*, users(id, username, email, role)')
      .eq('project_id', projectId);

    if (error) throw error;
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Tambah anggota ke proyek
exports.addProjectMember = async (req, res) => {
  try {
    const { project_id, user_id, project_role = 'Staff' } = req.body;

    if (!project_id || !user_id) {
      return res.status(400).json({ error: 'project_id dan user_id wajib diisi' });
    }

    const { data, error } = await supabase
      .from('project_members')
      .insert([{ project_id, user_id, project_role }])
      .select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Hapus anggota dari proyek
exports.removeProjectMember = async (req, res) => {
  try {
    const { projectId, userId } = req.params;
    const { error } = await supabase
      .from('project_members')
      .delete()
      .eq('project_id', projectId)
      .eq('user_id', userId);

    if (error) throw error;
    res.status(200).json({ message: "Member removed successfully" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Finalize proyek jadi completed
exports.finalizeProject = async (req, res) => {
  try {
    const { projectId } = req.params;
    const { data, error } = await supabase
      .from('projects')
      .update({ status: 'Completed' })
      .eq('id', projectId)
      .select();

    if (error) throw error;
    res.status(200).json(data[0]);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

//  user yang belum jadi anggota proyek ini
exports.getAvailableUsers = async (req, res) => {
  try {
    const { projectId } = req.params;

    const { data: members, error: memberError } = await supabase
      .from('project_members')
      .select('user_id')
      .eq('project_id', projectId);

    if (memberError) throw memberError;

    const memberIds = members.map(m => m.user_id);

    let query = supabase.from('users').select('id, username, email, role');
    if (memberIds.length > 0) {
      query = query.not('id', 'in', `(${memberIds.join(',')})`);
    }

    const { data: users, error: userError } = await query;
    if (userError) throw userError;

    res.status(200).json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
