"""
Setup script for AutoCAD-Excel Integration Toolkit
"""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="autocad-tools",
    version="1.0.0",
    author="AutoCAD-tools",
    description="A diverse toolkit of intelligent tools that utilize Excel for AutoCAD integration",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/ecnepsyroc-bot/AutoCAD-tools",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Intended Audience :: End Users/Desktop",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: Office/Business",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.8",
    install_requires=[
        "openpyxl>=3.1.0",
        "pandas>=2.0.0",
        "ezdxf>=1.1.0",
        "numpy>=1.24.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.0",
            "black>=23.0",
            "flake8>=6.0",
        ],
    },
)
