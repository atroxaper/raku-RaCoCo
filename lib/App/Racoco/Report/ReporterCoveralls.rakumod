use App::Racoco::Report::Reporter;
use App::Racoco::Report::DataPart;
use App::Racoco::Report::Data;
use App::Racoco::Properties;
use App::Racoco::Report::ReporterCoveralls::MD5;
use App::Racoco::Report::ReporterCoveralls::Git;
use App::Racoco::Report::ReporterCoveralls::Factory;

unit class App::Racoco::Report::ReporterCoveralls does Reporter is export;

has MD5 $!md5 = Factory::create-md5();
has Git $!git = Git.new;
has Transport $!transport = Factory::create-transport;

method do(IO::Path:D :$lib, Data:D :$data, Properties:D :$properties) {
	my $json = self.make-json(:$lib, :$data, p => $properties);
	$!transport.send($json);
}

method make-json(:$lib!, :$data!, :$p!) {
	qq:to/END/.trim;
	\{
	"repo_token":"{self.get-repo-token(:$p)}",
	"service_name":"{self.get-service-name(:$p)}",
	"service_number":"{self.get-service-number(:$p)}",
	"service_job_id":"{self.get-service-job-id(:$p)}",
	"service_pull_request":"{self.get-service-pull-request(:$p)}",
	"source_files": [
		{self.make-source-files-json(:$lib, :$data)}
	],
	"git": {self.make-git(:$p)}
	}
	END
}

method make-source-files-json(:$lib, :$data) {
	$data.get-all-parts.map(-> $part {
		my $content = $lib.add($part.file-name).slurp;
		my $coverage = self.coverage-line(:$lib, :$content, :$part)
	}).join(",\n");
}

method coverage-line(:$lib, :$content, :$part) {
	my $lib-name = $lib.basename;
	my $lines = $content.lines.elems;
	my $name = q/"name":"/ ~ $lib-name ~ '/' ~ $part.file-name ~ '",';
	my $source-digest = q/"source_digest":"/ ~ $!md5.md5($content) ~ '",';
	my $coverage = q/"coverage":[/ ~
		(1..$lines).map(-> $line { $part.hit-times-of(:$line) // 'null' }).join(',') ~ ']';
	join "\n", '{', $name, $source-digest, $coverage, '}';
}

method make-git(:$p!) {
	my $remote := $!git.get-git(:$p, :remote).sort(*.key).first;
	qq:to/END/.trim
	\{
		"head":\{
			"id":"{$!git.get-git(:$p, :hash)}",
			"author_name":"{$!git.get-git(:$p, :author)}",
			"author_email":"{$!git.get-git(:$p, :email)}",
			"committer_name":"{$!git.get-git(:$p, :committer)}",
			"committer_email":"{$!git.get-git(:$p, :committer-email)}",
			"message":"{$!git.get-git(:$p, :message)}"
		},
		"branch":"{$!git.get-git(:$p, :branch)}",
		"remotes": [
			\{
				"name":"{$remote.key}",
				"url": "{$remote.value}"
			}
		]
	}
	END
}

method get-repo-token(:$p!) {
	return $p.env-only('GITHUB_TOKEN') if $.is-github(:$p);
	$p.env-only('COVERALLS_REPO_TOKEN') //
	$p.property('repo_token') //
	''
}

method get-service-name(:$p!) {
	return $p.property('github_service_name') // 'github-actions' if $.is-github(:$p);
	$p.env-only('COVERALLS_SERVICE_NAME') //
	$p.property('service_name') //
	''
}

method get-service-number(:$p!) {
	return $p.env-only('GITHUB_RUN_ID') if $.is-github(:$p);
	return $p.env-only('CI_PIPELINE_IID') if $.is-gitlab(:$p);
	$p.env-only('COVERALLS_SERVICE_NUMBER') //
	$p.property('service_number') //
	''
}

method get-service-job-id(:$p!) {
	return '' if $.is-github(:$p);
	$p.env-only('COVERALLS_SERVICE_JOB_ID') //
	$p.property('service_job_id') //
	''
}

method get-service-pull-request(:$p!) {
	if $.is-github(:$p) {
		my $ref = $p.env-only('GITHUB_REF');
		if $ref.defined && $ref.starts-with('refs/pull/') {
			return $ref.split('/')[*- 1];
		}
		return '';
	}
	''
}

method is-github(:$p!) {
	$p.env-only('GITHUB_ACTIONS').defined
}

method is-gitlab(:$p!) {
	$p.env-only('GITLAB_CI').defined
}