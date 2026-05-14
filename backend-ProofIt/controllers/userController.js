const supabase = require('../supabaseClient');

// 1. Get All Users
exports.getAllUsers = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .order('username', { ascending: true });

        if (error) throw error;
        res.status(200).json(data);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 2. Create User
exports.createUser = async (req, res) => {
    try {
        const { username, email, password_hash, role } = req.body;
        const { data, error } = await supabase
            .from('users')
            .insert([{ username, email, password_hash, role }])
            .select();

        if (error) throw error;
        res.status(201).json({ success: true, data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 3. Update User
exports.updateUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { username, email, role } = req.body;
        const { error } = await supabase
            .from('users')
            .update({ username, email, role })
            .eq('id', id);

        if (error) throw error;
        res.status(200).json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 4. Delete User
exports.deleteUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await supabase
            .from('users')
            .delete()
            .eq('id', id);

        if (error) throw error;
        res.status(200).json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};