import "dotenv/config";
import { eq } from "drizzle-orm";
import { usersTable } from "../schema";
import { createDb } from "../client";

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
  throw new Error("DATABASE_URL environment variable is not set.");
}

const db = createDb(databaseUrl);

const user: typeof usersTable.$inferInsert = {
  name: "John",
  age: 30,
  email: "john@example.com",
};

// Wrap the whole task in one async IIFE so ESLint is happy
await (async () => {
  try {
    await db.insert(usersTable).values(user);
    console.log("New user created!");

    const users = await db.select().from(usersTable);
    console.log("Getting all users from the database: ", users);
    /*
      const users: {
        id: number;
        name: string;
        age: number;
        email: string;
      }[]
      */

    await db
      .update(usersTable)
      .set({
        age: 31,
      })
      .where(eq(usersTable.email, user.email));
    console.log("User info updated!");

    // await db.delete(usersTable).where(eq(usersTable.email, user.email));
    // console.log("User deleted!");
  } catch (err) {
    console.error("Database clean failed:", err);
    process.exitCode = 1; // set exit code, defer exit to finally
  } finally {
    process.exit();
  }
})();
