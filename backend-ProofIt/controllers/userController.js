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
        const { username, email, password, role } = req.body;
        const { data, error } = await supabase
            .from('users')
            .insert([{ username, email, password_hash: password, role }])
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

// 5. Debug Database (Untuk melihat isi kolom & daftar user terdaftar secara aman)
exports.debugDb = async (req, res) => {
    try {
        // Query user spesifik ardi@pixelforge.com
        const { data: ardiData, error: ardiError } = await supabase
            .from('users')
            .select('*')
            .eq('email', 'ardi@pixelforge.com')
            .maybeSingle();

        const { data: users, error: usersError } = await supabase
            .from('users')
            .select('*');

        if (usersError) {
            return res.status(500).json({
                error: 'Gagal mengambil data dari tabel users',
                message: usersError.message,
                details: usersError
            });
        }

        const safeUsers = users.map(u => {
            const keys = Object.keys(u);
            return {
                id: u.id,
                username: u.username,
                email: u.email,
                role: u.role,
                available_columns: keys
            };
        });

        res.status(200).json({
            message: 'Koneksi Supabase Sukses!',
            total_users: users.length,
            users: safeUsers,
            debug_ardi: ardiData ? {
                id: ardiData.id,
                username: ardiData.username,
                email: ardiData.email,
                password_hash_value: ardiData.password_hash,
                password_hash_length: ardiData.password_hash ? ardiData.password_hash.length : 0,
                // Check for hidden whitespace characters
                password_hash_chars: ardiData.password_hash ? ardiData.password_hash.split('') : []
            } : 'User ardi@pixelforge.com tidak ditemukan di database!'
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};