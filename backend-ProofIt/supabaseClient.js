const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
// Mendukung SUPABASE_KEY atau SUPABASE_ANON_KEY (bawaan integrasi Supabase di Railway)
const supabaseKey = process.env.SUPABASE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL atau SUPABASE_KEY/SUPABASE_ANON_KEY belum diset di .env atau Environment Variables.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;