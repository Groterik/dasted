import std.stdio;
import std.getopt;
import std.file;
import std.path;
import std.range;
import messages;

import dastedserver;

int main(string[] args)
{
    ushort port = 11344;
    bool printVersion;
    string dmdconf;
    bool daemon;

    getopt(args,
        "d|daemon", &daemon,
        "port|p", &port,
        "version", &printVersion,
        "dmdconf", &dmdconf);

    if (printVersion)
    {
        writeln(PROTOCOL_VERSION);
        return 0;
    }

    if (daemon && port <= 0)
    {
        writeln("Invalid port number");
        return 1;
    }

    Dasted d = new Dasted;

    if (!dmdconf.empty() && exists(dmdconf) && isFile(dmdconf))
    {
        import std.regex, std.conv;
        auto r = regex("-I([^ ]*)");
        auto f = File(dmdconf);
        foreach (line; f.byLine)
        {
            foreach (m; matchAll(line, r))
            {
                d.addImportPath(to!string(m.captures[1]));
            }
        }
    }

    if (daemon)
    {
        d.run(port);
    }
    else
    {
        import std.conv;
        import std.json;
        import msgpack;
        auto inputJsonString = stdin.byLine.join("\n");
        auto j = parseJSON(inputJsonString);
        auto type = j["type"].integer();
        auto msg = msgpack.fromJSONValue(j["msg"]).pack();
        auto rep = d.runOn(msg, to!MessageType(type));
        writeln(rep.unpack().toJSONValue().toString());

    }
    return 0;
}
