const supabase = require('../supabaseClient');

//Ambil semua notifikasi berdasarkan User ID
exports.getNotifications = async (req, res) => {
    try {
        const { userId } = req.params;
        const { data, error } = await supabase
            .from('notifications')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.status(200).json({ data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

//Hitung jumlah notifikasi yang belum dibaca
exports.getUnreadCount = async (req, res) => {
    try {
        const { userId } = req.params;
        const { count, error } = await supabase
            .from('notifications')
            .select('*', { count: 'exact', head: true })
            .eq('user_id', userId)
            .eq('is_read', false);

        if (error) throw error;
        res.status(200).json({ unread_count: count });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

//Tandai SATU notifikasi sebagai dibaca
exports.markAsRead = async (req, res) => {
    try {
        const { notifId } = req.params;
        const { error } = await supabase
            .from('notifications')
            .update({ is_read: true })
            .eq('id', notifId);

        if (error) throw error;
        res.status(200).json({ message: "Notification marked as read" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Tandai SEMUA notifikasi user sebagai dibaca
exports.markAllRead = async (req, res) => {
    try {
        const { userId } = req.params;
        const { error } = await supabase
            .from('notifications')
            .update({ is_read: true })
            .eq('user_id', userId);

        if (error) throw error;
        res.status(200).json({ message: "All notifications marked as read" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};