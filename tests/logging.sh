source common.sh

clearStore

exit 0

# Produce an escaped log file.
set -x
path=$(nix-build --log-type escapes -vv dependencies.nix --no-out-link 2> $TEST_ROOT/log.esc)

# Convert it to an XML representation.
nix-log2xml < $TEST_ROOT/log.esc > $TEST_ROOT/log.xml

# Is this well-formed XML?
if test "$xmllint" != "false"; then
    $xmllint --noout $TEST_ROOT/log.xml || fail "malformed XML"
fi

# Convert to HTML.
if test "$xsltproc" != "false"; then
    (cd $datadir/nix/log2html && $xsltproc mark-errors.xsl - | $xsltproc log2html.xsl -) < $TEST_ROOT/log.xml > $TEST_ROOT/log.html
    # Ideally we would check that the generated HTML is valid...

    # A few checks...
    grep "<code>.*FOO" $TEST_ROOT/log.html || fail "bad HTML output"
fi

# Test nix-store -l.
[ "$(nix-store -l $path)" = FOO ]

# Test compressed logs.
clearStore
rm -rf $NIX_LOG_DIR
! nix-store -l $path
nix-build dependencies.nix --no-out-link --option build-compress-log true
[ "$(nix-store -l $path)" = FOO ]
