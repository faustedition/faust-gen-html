#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
import sys
import re


"""
Removes whitespace-only diff chunks.
"""


def _chomp_line(line):
    """
    Removes a trailing newline from the given line, if any.
    >>> _chomp_line('Foo\\n')
    'Foo'
    """
    if line.endswith('\n'):
        return line[:-1]
    else:
        return line


def _shorten(lines, limit=15, gap=' … '):
    if len(lines) == 0:
        return "<empty>"
    else:
        start = lines[0][:limit]
        end = lines[-1][-limit:]
        if len(lines) == 1:
            if len(lines[0]) < 2*limit:
                return lines[0]
        return gap.join([start, end])


def chomp(lines):
    r"""
    Removes a trailing newline from the given line or lines.

    :param lines: If this is a ``str``, returns a chomped version of the
    string. Otherwise, it should be an iterable over lines, and the result will
    be an iterable over the chomped lines.

    >>> list(chomp("Foo\n"))
    ['Foo']
    >>> list(chomp(["Foo\n", "Bar\n"]))
    ['Foo', 'Bar']
    """
    if isinstance(lines, str):
        yield _chomp_line(lines)
    else:
        for line in lines:
            yield _chomp_line(line)


class WrongType(Exception):

    """
    Thrown when trying to add a line to a :class:`Stretch` that doesn't match
    the Stretch's type.
    """

    def __init__(self, stretch, line):
        self.stretch = stretch
        self.line = line

    def __str__(self):
        return "Cannot add line {} to stretch of type {}".format(
            self.line,
            self.stretch.type)


class Stretch:

    """
    A stretch represents a consecutive list of lines of the same type in a diff
    :class:`Chunk`. A stretch has a type (' ', '-', '+') and a list of lines.

    >>> s = Stretch().add('+Foo')
    >>> s.type
    '+'
    """

    def __init__(self):
        self.type = None
        self._lines = []

    def add(self, line):
        r"""
        Adds a line to this stretch.

        Line must begin with the type character
        from the raw diff. Raises a :class:`WrongType` if you add multiple lines
        of differing types.

        >>> s = Stretch().add('+Foo').add('+Bar')
        >>> str(s)
        '+Foo\n+Bar\n'
        >>> s.add('-Broken')
        Traceback (most recent call last):
            ...
        del_wsp_diffs.WrongType: Cannot add line -Broken to stretch of type +
        """
        if self.type is None:
            if line[0] in ('+', '-', ' '):
                self.type = line[0]
            else:
                raise Exception("Invalid type: " + line[0])
        elif self.type != line[0]:
            raise WrongType(self, line)
        self._lines.append(line[1:])
        return self

    def lines(self):
        r"""
        Returns a list of the lines, including trailing newline.

        >>> list(Stretch().add('+Foo').add('+Bar').lines())
        ['+Foo\n', '+Bar\n']
        """
        for line in self._lines:
            yield self.type + line + "\n"

    def equivalent_ignore_wsp(self, other):
        """
        Two stretches are text-equivalent if they do not differ except for
        whitespace.
        """

        WSP = re.compile('\s+')
        stripped_self = WSP.sub("", "".join(self._lines))
        stripped_other = WSP.sub("", "".join(other._lines))
        equiv = stripped_other == stripped_self
        return equiv

    def equivalent(self, other):
        r"""

        >>> s1 = Stretch().add('+Foo').add('+Bar ')
        >>> s2 = Stretch().add('-FooBar')
        >>> s3 = Stretch().add('-Fool').add('-Bar')
        >>> s1.equivalent(s2)
        True
        >>> s2.equivalent(s1)
        True
        >>> s1.equivalent(s3)
        False
        """
        return ((self.type == '+' and other.type == '-'
                 or self.type == '-' and other.type == '+')
                and self.equivalent_ignore_wsp(other))

    def __str__(self):
        return "".join(self.lines())

    def __repr__(self):
        return "<Stretch {0} ({1} lines: {2})>".format(
            self.type,
            len(self._lines),
            _shorten(self._lines))


class Chunk:

    def __init__(self, header):
        self.header = header
        self.stretches = [Stretch()]

    def add(self, line):
        r"""
        >>> chunk = Chunk('@@ -3007,7 +3019,8 @@') \
        ...    .add(' Alle Liebesgötter malen.') \
        ...    .add(' Itzund soll er nur die Schöne') \
        ...    .add(' Pesnen oder Harpern malen.') \
        ...    .add('-»Auf! Vortreflichster der Maler!1') \
        ...    .add('+»Auf! Vortreflichster der Maler!') \
        ...    .add('+1') \
        ...    .add(' Auf, und schildre, Preis der Maler!') \
        ...    .add(' Meister in der Kunst der Rhoder,') \
        ...    .add(' Komm, und schildre diese Schöne,')
        >>> print(chunk)
        @@ -3007,7 +3019,8 @@
         Alle Liebesgötter malen.
         Itzund soll er nur die Schöne
         Pesnen oder Harpern malen.
        -»Auf! Vortreflichster der Maler!1
        +»Auf! Vortreflichster der Maler!
        +1
         Auf, und schildre, Preis der Maler!
         Meister in der Kunst der Rhoder,
         Komm, und schildre diese Schöne,
        <BLANKLINE>
        """
        try:
            self.stretches[-1].add(line)
        except WrongType:
            self.stretches.append(Stretch().add(line))
        return self

    def lines(self):
        yield self.header + "\n"
        for stretch in self.stretches:
            for line in stretch.lines():
                yield line

    def __str__(self):
        return "".join(self.lines())

    def is_relevant(self):
        r"""
        >>> chunk = Chunk('@@ -3007,7 +3019,8 @@') \
        ...    .add(' Alle Liebesgötter malen.') \
        ...    .add(' Itzund soll er nur die Schöne') \
        ...    .add(' Pesnen oder Harpern malen.') \
        ...    .add('-»Auf! Vortreflichster der Maler!1') \
        ...    .add('+»Auf! Vortreflichster der Maler!') \
        ...    .add('+1') \
        ...    .add(' Auf, und schildre, Preis der Maler!') \
        ...    .add(' Meister in der Kunst der Rhoder,') \
        ...    .add(' Komm, und schildre diese Schöne,')
        >>> chunk.is_relevant()
        False
        """
        # Iterate over the stretches.
        # Since ``-`` appears before ``+``, following cases may occur:
        # +---------+----------+--------------+
        # | current | previous | resolution   |
        # |---------+----------+--------------|
        # | `` ``   | ``None`` | ignored      |
        # | `` ``   | `` ``    | ignored      |
        # | ``-``   | `` ``    | nop          |
        # | ``+``   | ``-``    | = equivalent |
        # | ``+``   | `` ``    | insertion    |
        # | `` ``   | ``-``    | deletion     |
        # +---------+----------+--------------+
        previous = None
        for current in self.stretches:
            if current.type == ' ' and previous is not None:
                if previous.type == '-':
                    return "Deletion"
            elif current.type == '+':
                if previous is None or previous.type == ' ':
                    return "Addition"
                if previous.type == '-' and not(current.equivalent(previous)):
                    return "Modification"
            previous = current
        if previous is not None and previous.type == '-':
            return "Deletion at end"

    def transform_irrelevant_stretches(self):
        """
        Transforms all 'irrelevant' stretches to context stretches
        """
        previous = None
        for current in self.stretches:
            if previous is not None \
                    and previous.type == '-' and current.type == '+' \
                    and current.equivalent(previous):
                current.type = ' '
                previous.type = '*'
            previous = current
        self.stretches = [s for s in self.stretches if s.type != '*']

    def __bool__(self):
        return not(self.is_relevant())

    def __repr__(self):
        relevance = "RELEVANT" if self.is_relevant() else "(irrelevant)"
        types = [stretch.type for stretch in self.stretches]
        return "<Chunk '{}' {} ({} stretches: {})>".format(
            self.header, relevance, len(self.stretches), "".join(types))


class Diff:

    def __init__(self, lines):
        self.head = []
        self.chunks = []
        if lines is not None:
            self._parse(lines)

    def _parse(self, lines):
        for line in chomp(lines):
            if line and line[0] == '@':
                self.chunks.append(Chunk(line))
            elif self.chunks:
                self.chunks[-1].add(line)
            else:
                self.head.append(line)

    def lines(self):
        if self.chunks:
            for line in self.head:
                yield line + "\n"
            for chunk in self.chunks:
                for line in chunk.lines():
                    yield line
        else:
            return 

    def __str__(self):
        return "".join(self.lines())

    def filtered(self):
        result = Diff(None)
        result.head = self.head
        result.chunks = [chunk for chunk in self.chunks if chunk.is_relevant()]
        return result

    def __bool__(self):
        return bool(self.chunks)


def main():
    parser = argparse.ArgumentParser(
        description="Filters whitespace-only diffs from a diff file.",
        epilog="""
            This command will remove all chunks that do not contain any
            differences except for newline modifications. If anything remains,
            it exits with a nonzero value.
            """)
    parser.add_argument(
        '-q',
        '--quiet',
        action='store_true',
        help="Don't output the filtered diff, "
             "just return whether something remains.")
    parser.add_argument('-v', '--verbose', action='store_true',
                        help="Print some status info.")
    parser.add_argument('-f', '--filter-chunks', action='store_true',
                        help="""
                        Convert all irrelevant stretches inside a (relevant)
                        chunk to context stretches.
                        """)
    parser.add_argument('diff', nargs='*',
                        help="""
            Diff file(s) to filter. If not given, we'll use stdin. If more than
            one given, they will be concatenated. Files must be in the format
            produced by diff -u.
            """)
    options = parser.parse_args()

    diffcount = 0
    output = sys.stdout
    for diff in options.diff:
        with open(diff) as infile:
            if options.verbose:
                print(diff, ':', end='', file=sys.stderr)
            parsed = Diff(infile)
            filtered = parsed.filtered()
            if options.filter_chunks:
                for chunk in filtered.chunks:
                    chunk.transform_irrelevant_stretches()
            if options.verbose:
                print(len(parsed.chunks),
                      'chunks,',
                      len(filtered.chunks),
                      'remain ->',
                      "DIFFERENT" if filtered else "EQUIVALENT",
                      file=sys.stderr)
            if not(options.quiet):
                output.writelines(filtered.lines())

            elif filtered and not(options.verbose):
                sys.exit(1)
            else:
                diffcount += 1
    if diffcount:
        sys.exit(1)

if __name__ == '__main__':
    main()
