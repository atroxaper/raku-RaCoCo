use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::ModuleNames;
use TestHelper;

plan 3;

sub setup() {
	plan $*plan;
}

'01-module-parts'.&test(:4plan, {
	setup();
	is module-parts(path => 'dir1/dir2/dir3/file.rakumod'.IO), <dir1 dir2 dir3 file>.List;
	is module-parts(path => '/dir1/dir2/dir3/file.rakumod'.IO), <dir1 dir2 dir3 file>.List;
	is module-parts(path => 'dir1/dir2/dir3/file'.IO), <dir1 dir2 dir3 file>.List;
	is module-parts(path => '/dir1/dir2/dir3/file'.IO), <dir1 dir2 dir3 file>.List;
});

'02-module-name'.&test(:4plan, {
	setup();
	is module-name(path => 'dir1/dir2/dir3/file.rakumod'.IO), 'dir1::dir2::dir3::file';
	is module-name(path => '/dir1/dir2/dir3/file.rakumod'.IO), 'dir1::dir2::dir3::file';
	is module-name(path => 'dir1/dir2/dir3/file'.IO), 'dir1::dir2::dir3::file';
	is module-name(path => '/dir1/dir2/dir3/file'.IO), 'dir1::dir2::dir3::file';
});

'03-file-precomp-path'.&test(:1plan, {
	setup();
	my $lib = '/home/author/projects/module/lib'.IO;
	is file-precomp-path(path => 'dir1/dir2/dir3/file.rakumod'.IO, :$lib),
		'B7'.IO.add('B7E0FD976577C721036834DB17F280990D5FFE1F');
});

done-testing

