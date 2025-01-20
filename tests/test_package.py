from package.methods import method


def test_1():
    time = method()
    assert time != "" and time is not None
