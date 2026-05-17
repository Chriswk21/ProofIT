const supabase = require('../supabaseClient');
const multer = require('multer');
const path = require('path');

const storage = multer.memoryStorage();

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 5 * 1024 * 1024, 
    },
    fileFilter: (req, file, cb) => {
       
        const ext = path.extname(file.originalname).toLowerCase();
        const allowedExts = ['.jpg', '.jpeg', '.png', '.webp', '.pdf'];

        if (allowedExts.includes(ext)) {
            cb(null, true); 
        } else {
            cb(new Error(`Tipe file tidak valid! Ekstensi ${ext} tidak diperbolehkan. Hanya menerima JPG, PNG, WEBP, atau PDF.`), false);
        }
    }
});

exports.uploadMiddleware = (req, res, next) => {
    const multerUpload = upload.single('file');

    multerUpload(req, res, function (err) {
        if (err instanceof multer.MulterError) {
            return res.status(400).json({ error: `Upload gagal: ${err.message}` });
        } else if (err) {
            return res.status(400).json({ error: err.message });
        }
        next();
    });
};

const BUCKET_NAME = 'chat_attachments';

exports.uploadFile = async (req, res) => {
    try {
        const file = req.file;
        if (!file) {

            return res.status(400).json({ error: 'Tidak ada file yang dikirim' });
        }


        const timestamp = Date.now();
        const safeFileName = file.originalname.replace(/[^a-zA-Z0-9._-]/g, '_');
        const filePath = `uploads/${timestamp}_${safeFileName}`;

        const { data, error } = await supabase.storage
            .from(BUCKET_NAME)
            .upload(filePath, file.buffer, {
                contentType: file.mimetype,
                upsert: false,
            });

        if (error) {
            console.error('Supabase upload error:', error);
            throw error;
        }
        const { data: urlData } = supabase.storage
            .from(BUCKET_NAME)
            .getPublicUrl(filePath);

        res.status(200).json({
            url: urlData.publicUrl,
            fileName: file.originalname,
        });
    } catch (err) {
        console.error('Upload error:', err);
        res.status(500).json({ error: err.message });
    }
};


exports.getForumMessages = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('forum_messages')
            .select('*')
            .eq('project_id', req.params.projectId)
            .order('created_at', { ascending: true });

        if (error) throw error;
        res.status(200).json(data);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.addMessage = async (req, res) => {
    try {
        const { project_id, user_id, message, attachment_url, reply_to_text, reply_to_id } = req.body;
        const { data, error } = await supabase
            .from('forum_messages')
            .insert([{ project_id, user_id, message, attachment_url, reply_to_text, reply_to_id }])
            .select();

        if (error) throw error;
        res.status(201).json(data[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.editMessage = async (req, res) => {
    try {
        const { error } = await supabase
            .from('forum_messages')
            .update({ message: req.body.message })
            .eq('id', req.params.id);

        if (error) throw error;
        res.status(200).json({ message: "Updated" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.deleteMessage = async (req, res) => {
    try {
        const { error } = await supabase.from('forum_messages').delete().eq('id', req.params.id);
        if (error) throw error;
        res.status(200).json({ message: "Deleted" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};