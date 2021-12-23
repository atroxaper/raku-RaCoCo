use App::Racoco::RunProc;
use App::Racoco::Report::ReporterCoveralls::Factory;

unit class App::Racoco::Report::ReporterCoveralls::Git is export;

has RunProc $!proc = Factory::create-proc;

multi method get-git(:hash($)!, :$properties! --> Str) {
	self!git-log-format('%H') // $properties.property('GIT_ID') // ''
}

multi method get-git(:author($)!, :$properties! --> Str) {
	self!git-log-format('%aN') // $properties.property('GIT_AUTHOR_NAME') // ''
}

multi method get-git(:email($)!, :$properties! --> Str) {
	self!git-log-format('%ae') // $properties.property('GIT_AUTHOR_EMAIL') // ''
}

multi method get-git(:committer($)!, :$properties! --> Str) {
	self!git-log-format('%cN') // $properties.property('GIT_COMMITTER_NAME') // ''
}

multi method get-git(:committer-email($)!, :$properties! --> Str) {
	self!git-log-format('%ce') // $properties.property('GIT_COMMITTER_EMAIL') // ''
}

multi method get-git(:message($)!, :$properties! --> Str) {
	self!git-log-format('%s') // $properties.property('GIT_MESSAGE') // ''
}

multi method get-git(:branch($)!, :$properties! --> Str) {
	self!github-branch(:$properties) //
	$properties.property('GIT_BRANCH') //
	autorun(:$!proc, :out, "git rev-parse --abbrev-ref HEAD")() //
	''
}

multi method get-git(:remote($)!, :$properties! --> Associative) {
	my $from-git = autorun(:$!proc, :out, "git remote -v")();
	with $from-git {
		return $from-git.lines.grep(*.contains: '(fetch)').map(*.split: ' ', :skip-empty).map({.[0] => .[1]}).Map
	} else {
		with $properties.property('GIT_REMOTE') {
			return %($_ => $properties.property('GIT_URL') // '')
		}
	}
	return %('' => '')
}

method !git-log-format($format --> Str) {
	autorun(:$!proc, :out, "git --no-pager log -1 --pretty=format:$format")()
}

method !github-branch(:$properties) {
	with $properties.env-only('GITHUB_REF') -> $ref {
		if $ref.starts-with('refs/heads/') or $ref.starts-with('refs/tags/') {
			return $ref.split('/')[*-1];
		}
	}
	return $_ with $properties.env-only('GITHUB_HEAD_REF');
}
