#!/usr/bin/env bash
test_description="encoding issues"
. $(dirname "$0")/test-lib.sh || exit 1

test_begin_subtest "Message with text of unknown charset"
add_message '[content-type]="text/plain; charset=unknown-8bit"' \
	    "[body]=irrelevant"
output=$(notmuch show id:${gen_msg_id} 2>&1 | notmuch_show_sanitize_all)
test_expect_equal "$output" "message{ id:XXXXX depth:0 match:1 excluded:0 filename:XXXXX
header{
Notmuch Test Suite <test_suite@notmuchmail.org> (2001-01-05) (inbox unread)
Subject: Message with text of unknown charset
From: Notmuch Test Suite <test_suite@notmuchmail.org>
To: Notmuch Test Suite <test_suite@notmuchmail.org>
Date: GENERATED_DATE
header}
body{
part{ ID: 1, Content-type: text/plain
irrelevant
part}
body}
message}"

test_begin_subtest "Search for ISO-8859-2 encoded message"
add_message '[content-type]="text/plain; charset=iso-8859-2"' \
            '[content-transfer-encoding]=8bit' \
            '[subject]="ISO-8859-2 encoded message"' \
            "[body]=$'Czech word tu\350\362\341\350\350\355 means pinguin\'s.'" # ISO-8859-2 characters are generated by shell's escape sequences
output=$(notmuch search tučňáččí 2>&1 | notmuch_show_sanitize_all)
test_expect_equal "$output" "thread:0000000000000002   2001-01-05 [1/1] Notmuch Test Suite; ISO-8859-2 encoded message (inbox unread)"

test_begin_subtest "RFC 2047 encoded word with spaces"
add_message '[subject]="=?utf-8?q?encoded word with spaces?="'
output=$(notmuch search id:${gen_msg_id} 2>&1 | notmuch_show_sanitize)
test_expect_equal "$output" "thread:0000000000000003   2001-01-05 [1/1] Notmuch Test Suite; encoded word with spaces (inbox unread)"

test_begin_subtest "RFC 2047 encoded words back to back"
add_message '[subject]="=?utf-8?q?encoded-words-back?==?utf-8?q?to-back?="'
output=$(notmuch search id:${gen_msg_id} 2>&1 | notmuch_show_sanitize)
test_expect_equal "$output" "thread:0000000000000004   2001-01-05 [1/1] Notmuch Test Suite; encoded-words-backto-back (inbox unread)"

test_begin_subtest "RFC 2047 encoded words without space before or after"
add_message '[subject]="=?utf-8?q?encoded?=word without=?utf-8?q?space?=" '
output=$(notmuch search id:${gen_msg_id} 2>&1 | notmuch_show_sanitize)
test_expect_equal "$output" "thread:0000000000000005   2001-01-05 [1/1] Notmuch Test Suite; encodedword withoutspace (inbox unread)"

test_done
