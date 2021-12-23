use Test;
use lib 'lib';
use App::Racoco::Report::ReporterCoveralls::Git;
use App::Racoco::RunProc;
use App::Racoco::Properties;
use lib 't/lib';
use Fixture;

plan 5;

subtest '01-from-proc', {
	plan 8;
	my $*create-proc = Fixture::mockProc(|%(
		'%H' => '_hash',
		'%aN' => '_author',
		'%ae' => '_author_email',
		'%cN' => '_commiter',
		'%ce' => '_commiter_email',
		'%s' => '_message',
		'--abbrev-ref' => '_branch',
		'remote' => "origin  origin.git (fetch)\norigin  origin.git (push)\nfork  fork.git (fetch)",
	));
	my $git = Git.new;
	my $properties = Properties.new(lib => $*TMPDIR.add('lib'));

	is $git.get-git(:$properties, :hash), '_hash', 'hash';
	is $git.get-git(:$properties, :author), '_author', 'author';
	is $git.get-git(:$properties, :email), '_author_email', 'email';
	is $git.get-git(:$properties, :committer), '_commiter', 'commiter';
	is $git.get-git(:$properties, :committer-email), '_commiter_email', 'commiter email';
	is $git.get-git(:$properties, :message), '_message', 'message';

	is $git.get-git(:$properties, :branch), '_branch', 'branch';

	is $git.get-git(:$properties, :remote), %(origin => 'origin.git', fork => 'fork.git'), 'remotes';
}

subtest '02-from-prop', {
	plan 8;
	my $*create-proc = Fixture::failProc;
	my $git = Git.new;
	my $properties = Properties.new(lib => $*TMPDIR.add('lib'));
	%*ENV<GIT_ID> = 'env_hash';
	%*ENV<GIT_AUTHOR_NAME> = 'env_author';
	%*ENV<GIT_AUTHOR_EMAIL> = 'env_author_email';
	%*ENV<GIT_COMMITTER_NAME> = 'env_commiter';
	%*ENV<GIT_COMMITTER_EMAIL> = 'env_commiter_email';
	%*ENV<GIT_MESSAGE> = 'env_message';
	%*ENV<GIT_BRANCH> = 'env_branch';
	%*ENV<GIT_REMOTE> = 'env_remote';
	%*ENV<GIT_URL> = 'env_remote_url';

	is $git.get-git(:$properties, :hash), 'env_hash', 'hash';
	is $git.get-git(:$properties, :author), 'env_author', 'author';
	is $git.get-git(:$properties, :email), 'env_author_email', 'email';
	is $git.get-git(:$properties, :committer), 'env_commiter', 'commiter';
	is $git.get-git(:$properties, :committer-email), 'env_commiter_email', 'commiter email';
	is $git.get-git(:$properties, :message), 'env_message', 'message';

	is $git.get-git(:$properties, :branch), 'env_branch', 'branch';

	is $git.get-git(:$properties, :remote), %(env_remote => 'env_remote_url'), 'remotes';
}

subtest '03-github-branch', {
	plan 6;
	my $*create-proc = Fixture::mockProc(|%(
		'--abbrev-ref' => 'git_branch',
	));
	my $git = Git.new;
	my $properties = Properties.new(lib => $*TMPDIR.add('lib'));
	%*ENV<GITHUB_REF> = 'refs/heads/heads_branch';
	%*ENV<GITHUB_HEAD_REF> = 'pull_request_branch';
	%*ENV<GIT_BRANCH> = 'env_branch';
	is $git.get-git(:$properties, :branch), 'heads_branch', 'guthub ref head';
	%*ENV<GITHUB_REF> = 'refs/tags/tags_branch';
	is $git.get-git(:$properties, :branch), 'tags_branch', 'guthub ref tags';
	%*ENV<GITHUB_REF> = 'blabla/heads_branch';
	is $git.get-git(:$properties, :branch), 'pull_request_branch', 'guthub ref wrong';
	%*ENV<GITHUB_REF>:delete;
	is $git.get-git(:$properties, :branch), 'pull_request_branch', 'guthub pull request';
	%*ENV<GITHUB_HEAD_REF>:delete;
	is $git.get-git(:$properties, :branch), 'env_branch', 'without guthub';
	%*ENV<GIT_BRANCH>:delete;
	is $git.get-git(:$properties, :branch), 'git_branch', 'without env';
}

subtest '04-empty-git', {
	plan 8;
	my $*create-proc = Fixture::failProc;
	my $git = Git.new;
	my $properties = Properties.new(lib => $*TMPDIR.add('lib'));
	%*ENV<GIT_ID>:delete;
	%*ENV<GIT_AUTHOR_NAME>:delete;
	%*ENV<GIT_AUTHOR_EMAIL>:delete;
	%*ENV<GIT_COMMITTER_NAME>:delete;
	%*ENV<GIT_COMMITTER_EMAIL>:delete;
	%*ENV<GIT_MESSAGE>:delete;
	%*ENV<GIT_BRANCH>:delete;
	%*ENV<GIT_REMOTE>:delete;
	%*ENV<GIT_URL>:delete;

	is $git.get-git(:$properties, :hash), '', 'hash';
	is $git.get-git(:$properties, :author), '', 'author';
	is $git.get-git(:$properties, :email), '', 'email';
	is $git.get-git(:$properties, :committer), '', 'commiter';
	is $git.get-git(:$properties, :committer-email), '', 'commiter email';
	is $git.get-git(:$properties, :message), '', 'message';

	is $git.get-git(:$properties, :branch), '', 'branch';

	is $git.get-git(:$properties, :remote), %('' => ''), 'remotes';
}

subtest '05-real-git-good', {
	my $*create-proc = RunProc.new;
	my $git = Git.new;
	my $properties = Properties.new(lib => $*TMPDIR.add('lib'));
	%*ENV<GIT_ID>:delete;
	ok $git.get-git(:$properties, :hash).chars > 0, 'real git';
}

done-testing