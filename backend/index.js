import dotenv from 'dotenv';
dotenv.config();

import app from './src/app.js';
import { ensureSchema } from './src/db/init.js';

const port = process.env.PORT || 4000;

(async () => {
	try {
		await ensureSchema();
	} catch (err) {
		console.error('Failed to ensure DB schema:', err);
	}
	app.listen(port, () => {
		console.log(`MedNet backend listening on port ${port}`);
	});
})();
