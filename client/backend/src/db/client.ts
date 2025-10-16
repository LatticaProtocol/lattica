import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";

// NOTE: This connection is synchronous and held open
export function createDb(connectionString: string) {
  const sql = neon(connectionString);
  return drizzle({ client: sql });
}

// NOTE: While this connection is serverless (each db transaction is executed as an HTTP request)
// import { drizzle } from 'drizzle-orm/neon-http';
//
// const db = drizzle(process.env.DATABASE_URL);
//
