package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Test::Mojo;
use MojoX::Util::BodyFilter;

    my $backup = $ENV{MOJO_MODE} || '';
    
    __PACKAGE__->runtests;
    
    sub single_filter : Test(4) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/index')
			->status_is(200)
			->header_like('Content-Type', qr{text/html})
			->content_is('original[filtered]');
    }
    
    sub dual_filter : Test(4) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp2');
        $t->get_ok('/index')
			->status_is(200)
			->header_like('Content-Type', qr{text/html})
			->content_is('original[filtered][filtered2]');
    }
    
    sub with_args : Test(4) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp3');
        $t->get_ok('/index')
			->status_is(200)
			->header_like('Content-Type', qr{text/html})
			->content_is('original[aaa]');
    }
    
    END {
        $ENV{MOJO_MODE} = $backup;
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Util::BodyFilter 'enable';
use lib 't/lib';

sub startup {
    my $self = shift;
	
	enable($self, [
		'TestFilter',
	]);
	
	$self->routes->route('/index')->to(cb => sub{
		$_[0]->render_text('original');
	});
}

package SomeApp2;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Util::BodyFilter 'enable';
use lib 't/lib';

sub startup {
    my $self = shift;
	
	enable($self, [
		'TestFilter',
		'TestFilter2',
	]);
	
	$self->routes->route('/index')->to(cb => sub{
		$_[0]->render_text('original');
	});
}

package SomeApp3;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Util::BodyFilter 'enable';
use lib 't/lib';

sub startup {
    my $self = shift;
	
	enable($self, [
		'TestFilter3' => [tag => 'aaa'],
	]);
	
	$self->routes->route('/index')->to(cb => sub{
		$_[0]->render_text('original');
	});
}

__END__
