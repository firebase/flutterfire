import { Octokit } from '@octokit/rest';
import { context } from '@actions/github';
import { franc } from 'franc-min';

const spamWords = [
  'pemain',
  'dan', // "and" in indonesian, very common
  'wallet wallet', // seems to be in most crypto issues
  'minecraft',
  'paybis',
  'blockchain',
  'your feature request title here',
  'documentation feedback title',
  'official contact number',
  'phantom wallet',
  'defi wallet',
  'dogecoin',
  'crypto.com',
  'moonpay',
  'coinmama',
  ['wallet', 'support'],
];

async function closeSpamIssues() {
  const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

  const issues = await octokit.paginate(octokit.rest.issues.listForRepo, {
    owner: context.repo.owner,
    repo: context.repo.repo,
    state: 'open',
  });

  for (const issue of issues) {
    const issueCreator = issue.user.login;
    const issueContent = `${issue.title} ${issue.body || ''}`.toLowerCase();
    const detectedLanguage = franc(issueContent);

    const spam = spamWords.find((wordOrArray) => {
      if (Array.isArray(wordOrArray)) {
        return wordOrArray.every((word) => issueContent.includes(word));
      } else {
        const wordWithSpace = ` ${wordOrArray} `;

        return issueContent.includes(wordWithSpace);
      }
    });

    if (spam || detectedLanguage === 'ind') {
      await octokit.rest.issues.update({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: issue.number,
        state: 'closed',
      });

      await octokit.rest.issues.addLabels({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: issue.number,
        labels: ['resolution: invalid', 'platform: all'],
      });

      console.log(
        `Closed issue #${issue.number} created by spam user: ${issueCreator} or detected as Indonesian language and added labels.`
      );
    }
  }
}

closeSpamIssues().then(() => {
  console.log('Successfully ran spam issue clean up');
});
