module convert;

import messages;
import dsymbols;
import logger;

import dparse.ast;
import dparse.lexer;
import dparse.parser;
import dparse.formatter;

import std.array;
import std.algorithm;
import std.conv;

alias messages.MSymbol MSymbol;

messages.SymbolType toUbyteType(dsymbols.SymbolType s)
{
    alias S = messages.SymbolType;
    switch (s)
    {
    default:
    case dsymbols.SymbolType.NO_TYPE:   return S.UNKNOWN;
    case dsymbols.SymbolType.CLASS:     return S.CLASS;
    case dsymbols.SymbolType.INTERFACE: return S.INTERFACE;
    case dsymbols.SymbolType.STRUCT:    return S.STRUCT;
    case dsymbols.SymbolType.UNION:     return S.UNION;
    case dsymbols.SymbolType.FUNC:      return S.FUNCTION;
    case dsymbols.SymbolType.TEMPLATE:  return S.TEMPLATE;
    case dsymbols.SymbolType.MODULE:    return S.MODULE;
    case dsymbols.SymbolType.PACKAGE:   return S.PACKAGE;
    case dsymbols.SymbolType.ENUM:      return S.ENUM;
    case dsymbols.SymbolType.ENUM_VAR:  return S.ENUM_VARIABLE;
    case dsymbols.SymbolType.VAR:       return S.VARIABLE;
    case dsymbols.SymbolType.BLOCK:     return S.BLOCK;
    case dsymbols.SymbolType.ALIAS:     return S.ALIAS;
    }
}

MSymbol toMSymbol(const(ISymbol) symbol)
{
    MSymbol s;
    if (symbol is null)
    {
        return s;
    }
    s.type = symbol.symbolType().toUbyteType();
    s.subType = to!(messages.SymbolSubType)(to!ubyte(symbol.symbolSubType()));
    s.location.filename = symbol.fileName();
    s.parameters = toStringList(symbol.parameters());
    s.templateParameters = toStringList(symbol.templateParameters());
    if (s.location.filename.empty())
    {
        s.location.filename = "stdin";
    }
    s.location.cursor = symbol.position;
    s.name = symbol.name();
    s.typeName = symbol.type().asString();
    return s;
}

MScope toMScope(const(ISymbol) symbol)
{
    MScope mscope;
    if (symbol is null)
    {
        return mscope;
    }
    mscope.symbol = toMSymbol(symbol);
    foreach (s; symbol.children())
    {
        mscope.children ~= toMScope(s);
    }
    return mscope;
}

string parameterToString(const(dsymbols.Parameter) param)
{
    string res = debugString(param.type);
    if (!res.empty)
    {
        res ~= " ";
    }
    res ~= param.name;
    return res;
}

string[] toStringList(const(ParameterList) params)
{
    return params.map!(a => a.parameterToString).array;
}
