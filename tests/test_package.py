from package.invoketime import invoke_time


def test_1():
    time = invoke_time()
    assert time != "" and time is not None
