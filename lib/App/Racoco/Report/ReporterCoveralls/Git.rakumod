use App::Racoco::RunProc;
use App::Racoco::Report::ReporterCoveralls::Factory;

unit class App::Racoco::Report::ReporterCoveralls::Git is export;

has RunProc $!proc = Factory::create-proc;

multi method get-git(:hash($)!, :$p! --> Str) {
	self!git-log-format('%H') // $p.property('GIT_ID') // ''
}

multi method get-git(:author($)!, :$p! --> Str) {
	self!git-log-format('%aN') // $p.property('GIT_AUTHOR_NAME') // ''
}

multi method get-git(:email($)!, :$p! --> Str) {
	self!git-log-format('%ae') // $p.property('GIT_AUTHOR_EMAIL') // ''
}

multi method get-git(:committer($)!, :$p! --> Str) {
	self!git-log-format('%cN') // $p.property('GIT_COMMITTER_NAME') // ''
}

multi method get-git(:committer-email($)!, :$p! --> Str) {
	self!git-log-format('%ce') // $p.property('GIT_COMMITTER_EMAIL') // ''
}

multi method get-git(:message($)!, :$p! --> Str) {
	self!git-log-format('%s') // $p.property('GIT_MESSAGE') // ''
}

multi method get-git(:branch($)!, :$p! --> Str) {
	self!github-branch(:$p) //
	$p.property('GIT_BRANCH') //
	autorun(:$!proc, :out, "git rev-parse --abbrev-ref HEAD")() //
	''
}

multi method get-git(:remote($)!, :$p! --> Associative) {
	my $from-git = autorun(:$!proc, :out, "git remote -v")();
	with $from-git {
		return $from-git.lines.grep(*.contains: '(fetch)').map(*.split: ' ', :skip-empty).map({.[0] => .[1]}).Map
	} else {
		with $p.property('GIT_REMOTE') {
			return %($_ => $p.property('GIT_URL') // '')
		}
	}
	return %('' => '')
}

method !git-log-format($format --> Str) {
	autorun(:$!proc, :out, "git --no-pager log -1 --pretty=format:$format")()
}

method !github-branch(:$p) {
	with $p.env-only('GITHUB_REF') -> $ref {
		if $ref.starts-with('refs/heads/') or $ref.starts-with('refs/tags/') {
			return $ref.split('/')[*-1];
		}
	}
	return $_ with $p.env-only('GITHUB_HEAD_REF');
}
