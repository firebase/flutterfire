import { Octokit } from "@octokit/rest";
import { context } from "@actions/github";
import {franc} from "franc-min";

const spamUsers = ['Krakensu', 'Botakjelek', 'pemainlama', 'imyourmanposs', 'clav-code', 'sarahagus', 'teisanilan', 'jagat3131', 'sorenmoren6', 'SDGTAL', 'jedaymc', 'eztillieiium', 'danasatria89', 'puput212306'];

async function closeSpamIssues() {
  const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

  const issues = await octokit.paginate(octokit.rest.issues.listForRepo, {
    owner: context.repo.owner,
    repo: context.repo.repo,
    state: 'open'
  });

  for (const issue of issues) {
    const issueCreator = issue.user.login;
    const issueContent = `${issue.title} ${issue.body || ''}`;
    const detectedLanguage = franc(issueContent);

    if (spamUsers.includes(issueCreator) || detectedLanguage === 'ind') {
      // await octokit.rest.issues.update({
      //   owner: context.repo.owner,
      //   repo: context.repo.repo,
      //   issue_number: issue.number,
      //   state: 'closed'
      // });

      // await octokit.rest.issues.addLabels({
      //   owner: context.repo.owner,
      //   repo: context.repo.repo,
      //   issue_number: issue.number,
      //   labels: ['resolution: invalid', 'platform: all']
      // });

      console.log(`Closed issue #${issue.number} created by spam user: ${issueCreator} or detected as Indonesian language and added labels.`);
    }
  }
}

closeSpamIssues().catch(error => console.error(error));
