from textwrap import dedent


def clean_text(text):
    return dedent(text).strip()


def assert_equal(actual, expected):
    assert clean_text(actual.read()) == clean_text(expected)
