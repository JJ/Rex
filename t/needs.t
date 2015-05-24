package MyTest;

use strict;
use warnings;

$::QUIET = 1;

use Rex::Commands;

desc("MyTest - Test1");
task(
  "test1",
  sub {
    open( my $fh, ">", "test1.txt" );
    close($fh);
  }
);

desc("MyTest - Test2");
task(
  "test2",
  sub {
    open( my $fh, ">", "test2.txt" );
    close($fh);
  }
);

1;

package main;

use Test::More tests => 3;

use Rex::Commands;

desc("Test");
task(
  "test",
  sub {

    needs MyTest;

    if ( -f "test1.txt" && -f "test2.txt" ) {
      unlink("test1.txt");
      unlink("test2.txt");

      return 1;
    }

    is( 1, -1 );
  }
);

desc("Test 2");
task(
  "test2",
  sub {

    needs MyTest "test2";

    if ( -f "test2.txt" ) {
      unlink("test2.txt");
      return 1;
    }

    is( 1, -1 );

  }
);

desc("Test 3");
task(
  "test3",
  sub {

    needs("test4");

    if ( -f "test4.txt" ) {
      unlink("test4.txt");
      return 1;
    }

    is( 1, -1 );
  }
);

desc("Test 4");
task(
  "test4",
  sub {
    open( my $fh, ">", "test4.txt" );
    close($fh);
  }
);

ok( Rex::TaskList->create()->run("test"),  "testing needs" );
ok( Rex::TaskList->create()->run("test2"), "testing needs" );
ok( Rex::TaskList->create()->run("test3"), "testing needs - local namespace" );

1;

