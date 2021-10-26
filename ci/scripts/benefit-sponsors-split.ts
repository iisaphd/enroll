import { promises as fs } from 'fs';

import {
  FileWithRuntime,
  FileWithRuntimeDictionary,
  FileGroup,
} from './models';
import {
  createFileDictionary,
  createFilesWithRuntime,
  splitFilesIntoGroups,
} from './util';

const REPORT_PATH = './ci/rspec/components-benefit_sponsors-rspec-report.json';
const SPLIT_CONFIG_PATH = './ci/benefit_sponsors-split-config.json';

async function createSplitConfig(): Promise<void> {
  // Read cli arguments

  const report: string = await fs.readFile(REPORT_PATH, 'utf-8');

  const [manualGroupCountInput] = process.argv.slice(2);

  const groupCount: number | undefined =
    manualGroupCountInput !== undefined
      ? parseInt(manualGroupCountInput, 10)
      : undefined;

  const { examples } = JSON.parse(report);

  // Create a dictionary of
  const filesByRuntime: FileWithRuntimeDictionary =
    createFileDictionary(examples);

  const arrayOfSlowFiles: FileWithRuntime[] =
    createFilesWithRuntime(filesByRuntime);

  const shortenedPaths: FileWithRuntime[] = arrayOfSlowFiles.map((file) => {
    // This removes the `components/benefit_sponsors` from the path
    const shortenedFilePath = file.filePath.substring(28);

    const fileWithRuntime: FileWithRuntime = {
      filePath: shortenedFilePath,
      runTime: file.runTime,
    };

    return fileWithRuntime;
  });

  console.log('Creating split config');
  const splitConfig: FileGroup[] = splitFilesIntoGroups(
    shortenedPaths,
    groupCount
  );

  try {
    await fs.writeFile(SPLIT_CONFIG_PATH, JSON.stringify(splitConfig));
  } catch (e) {
    console.error(e);
  }
}

createSplitConfig();