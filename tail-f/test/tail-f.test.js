import { expect } from 'chai';
import puppeteer from 'puppeteer';
import fs from 'fs';
import { spawn } from 'child_process';

const TEST_PORT = 9090;

const TEST_URL = `http://localhost:${TEST_PORT}/log`;
const LOG_FILE = './app.log';

describe('Log tailing browser test', function () {
  let browser;
  let page;
  let serverProcess;

  this.timeout(10000);

  before((done) => {
    serverProcess = spawn('node', ['index.js'], {
      env: { ...process.env, PORT: TEST_PORT },
      stdio: 'inherit',
    });

    setTimeout(done, 2000);
  });

  beforeEach(async () => {
    fs.writeFileSync(LOG_FILE, '');
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

    fs.appendFileSync(LOG_FILE, logLine + '\n');

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
