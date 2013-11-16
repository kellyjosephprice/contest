package Contest;

use strict;
use warnings;

use Exporter qw{ import };
@EXPORT_OK = qw{
    info warn debug trace error fatal
};

sub info(@);
sub warn(@);
sub debug(@);
sub trace(@);
sub error(@);
sub fatal(@);

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    return $self;
}

sub init {
    my ($self, $opts) = @_;
    $self->get_logger();
}

sub info(@) { $self->{log}->info($_} for @_; }
sub warn(@) { $self->{log}->warn($_} for @_; }
sub debug(@) { $self->{log}->debug($_} for @_; }
sub trace(@) { $self->{log}->trace($_} for @_; }
sub error(@) { $self->{log}->error($_} for @_; }
sub fatal(@) { $self->{log}->fatal($_} for @_; }

sub get_logger {
    my ($self) = @_;

    my $log_config = q(
    log4perl.logger = INFO, WebErrorLog, SCREEN
    
    log4perl.appender.WebErrorLog               = Barracuda::Logging::Maybe_Unicode_File_Rotate
    log4perl.appender.WebErrorLog.filename      = /mail/log/apache/error_log
    log4perl.appender.WebErrorLog.mode          = append
    log4perl.appender.WebErrorLog.max           = 5
    log4perl.appender.WebErrorLog.size          = 10485760
    log4perl.appender.WebErrorLog.owner         = nobody
    log4perl.appender.WebErrorLog.group         = nogroup
    log4perl.appender.WebErrorLog.umask         = 0000
    log4perl.appender.WebErrorLog.permissions   = sub { use POSIX; S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH }
    log4perl.appender.WebErrorLog.recreate      = 1
    log4perl.appender.WebErrorLog.layout        = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.WebErrorLog.layout.ConversionPattern = [%d] %U:%L %p:  %m%n
    
    log4perl.appender.SCREEN         = Log::Log4perl::Appender::Screen
    log4perl.appender.SCREEN.stderr  = 0
    log4perl.appender.SCREEN.layout  = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.SCREEN.layout.ConversionPattern = [%d] %U:%L %p:  %m%n
    );
    Log::Log4perl::init(\$log_config);

    return $self->{log} = Log::Log4perl->get_logger();
}

1;
