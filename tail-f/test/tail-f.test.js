import { expect } from 'chai';
import puppeteer from 'puppeteer';
import fs from 'fs';
import { spawn } from 'child_process';
import path from 'path';

const TEST_PORT = 8080;
const TEST_URL = `http://localhost:${TEST_PORT}/log`;
const LOG_FILE = './app.log';

describe('Log tailing browser test', function () {
  let browser;
  let page;
  let serverProcess;

  this.timeout(10000); // Give it enough time for browser + socket

  before((done) => {
    // Start your server in a child process
    serverProcess = spawn('node', ['index.js'], {
      env: { ...process.env, PORT: TEST_PORT },
      stdio: 'inherit',
    });

    // Wait a moment for server to start
    setTimeout(done, 2000);
  });

  beforeEach(async () => {
    // Clear log file
    fs.writeFileSync(LOG_FILE, '');

    // Launch browser
    browser = await puppeteer.launch();
    page = await browser.newPage();
    await page.goto(TEST_URL);
  });

  afterEach(async () => {
    await browser.close();
  });

  after(() => {
    serverProcess.kill();
  });

  it('displays new log line added to app.log', async function () {
    const logLine = 'Test log entry ' + Date.now();

    // Append new line to log
    fs.appendFileSync(LOG_FILE, logLine + '\n');

    // Wait for content to appear in browser
    const content = await page.waitForFunction(
      (expected) => {
        const el = document.getElementById('log-container');
        return el && el.innerText.includes(expected);
      },
      { timeout: 3000 },
      logLine
    );

    expect(content).to.not.be.null;
  });
});
