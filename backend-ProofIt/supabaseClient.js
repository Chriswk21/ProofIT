const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

// Safe debug log for production troubleshooting
console.log('=== DEBUG ENVIRONMENT VARIABLES ===');
console.log('SUPABASE_URL detected:', !!supabaseUrl);
console.log('SUPABASE_KEY detected:', !!supabaseKey);
console.log('Available keys containing SUPABASE:', Object.keys(process.env).filter(k => k.includes('SUPABASE')));
console.log('====================================');

if (!supabaseUrl || !supabaseKey) {
  throw new Error(`SUPABASE_URL atau SUPABASE_KEY belum diset di .env / Environment Variables. (URL: ${!!supabaseUrl}, KEY: ${!!supabaseKey})`);
}

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;