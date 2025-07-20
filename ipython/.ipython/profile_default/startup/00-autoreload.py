try:
    from IPython import get_ipython
    ipython = get_ipython()
    if ipython:
        print("✅ Autoreload enabled")
        ipython.run_line_magic('load_ext', 'autoreload')
        ipython.run_line_magic('autoreload', '2')
except (ImportError, AttributeError):
    pass
