import fs from "fs";

for (let i = 0; i < 20; i++) {
    const date = new Date();
    fs.appendFileSync("./app.log", `${date.toISOString()}\n`);
    await new Promise((resolve) => setTimeout(resolve, 1000));
}