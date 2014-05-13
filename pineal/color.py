from imports import *

sys.path.insert(0, 'thirdparty/mattrobenolt/colors.py')
import colors

class Color:
    def __init__(self, h=0, map=None):
        self._h = float(h) if 0.0<=float(h)<=1.0 else float(h)%1.0
        if not map:
            self.grey()
        else:
            self.map = map

    # methods to map h to (r,g,b)
    # map() is the default
    def grey(self):
        self.map = self.grey
        self.r = self.g = self.b = self._h
    #

    def __float__(self):
        return self._h

    def __add__(self, f):
        return Color(self._h + f, self.map)
    __radd__ = __add__

    def __sub__(self, f):
        return Color(self._h - f, self.map)
    def __rsub__(self, f):
        return Color(f - self._h, self.map)

    def __div__(self, f):
        return Color(self._h / f, self.map)
    def __rdiv__(self, f):
        return Color(f / self._h, self.map)

    def __mul__(self, f):
        return Color(self._h * f, self.map)
    __rmul__ = __mul__
