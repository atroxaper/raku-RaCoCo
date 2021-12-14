use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::ModuleNames;
use TestHelper;

plan 2;

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

done-testing

