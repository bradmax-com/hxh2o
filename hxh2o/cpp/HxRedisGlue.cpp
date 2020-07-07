#include <hxcpp.h>
#include <HxRedisImport.h>
#include <stdio.h>
#include <iostream>
#include <vector>
#include "hiredis.h"

using namespace std;

::String _checkError(::cpp::Pointer<redisContext> c){
    bool isNull = c == NULL;
    bool err = ((redisContext *)c)->err;
    String errstr = String::create(((redisContext *)c)->errstr, 128);
    if(isNull){
        return String("Can't allocate redis context");        
    }else if(err){
        return errstr;
    }else{
        return String("");
    }
}

::cpp::Pointer<HXredisReply> _parseReply(redisReply *res, bool root){
    bool isNull = res == NULL;
    HXredisReply *rep = new HXredisReply();

    rep->error = false;
    rep->len = ((redisReply *)res)->len;
    rep->str = String::create(((redisReply *)res)->str);
    rep->type = ((redisReply *)res)->type;
    rep->integer = ((redisReply *)res)->integer;
    rep->elements = ((redisReply *)res)->elements;

    if(rep->elements > 0){
        rep->element = (struct HXredisReply **)calloc(rep->elements, sizeof(struct HXredisReply *));
        
        int i;
        for(i = 0 ; i < rep->elements ; i++){
            rep->element[i] = _parseReply(res->element[i], false);
        }
    }

    if(root == true) freeReplyObject(res);

    return rep;
}

int _redisAppendCommand(cpp::Pointer<redisContext> c, String cmd){
    return redisAppendCommand((redisContext *)c.get_raw(), cmd.__s);
}

int _redisAppendCommandArgv(cpp::Pointer<redisContext> c, int len, Array<Array<cpp::UInt8>> strArr, Array<int> lenArr){
    int i = 0;
    vector<const char *> argv;
    vector<size_t> argvlen;
    for(i=0 ; i < len ; i++){
        argv.push_back( strArr->__get(i)->getBase() );
        argvlen.push_back(lenArr->__get(i));
    }

    return redisAppendCommandArgv((redisContext *)c.get_raw(), len, &(argv[0]), &(argvlen[0]));
}

cpp::Pointer<HXredisReply> _redisCommandArgv(cpp::Pointer<redisContext> c, int len, Array<Array<cpp::UInt8>> strArr, Array<int> lenArr){
    int i = 0;
    vector<const char *> argv;
    vector<size_t> argvlen;
    for(i=0 ; i < len ; i++){
        argv.push_back( strArr->__get(i)->getBase() );
        argvlen.push_back(lenArr->__get(i));
    }

    redisReply *res = (redisReply *) redisCommandArgv((redisContext *)c.get_raw(), len, &(argv[0]), &(argvlen[0]));
    bool isNull = res == NULL;
    if(isNull){
        HXredisReply *err = new HXredisReply();
        err->error = true;
        err->str = String::create("");
        return err;
    }
    
    HXredisReply *rep = _parseReply(res, true);
    
    return rep;
}

cpp::Pointer<HXredisReply> _command(cpp::Pointer<redisContext> c, String cmd){
    redisReply *res = (redisReply *)redisCommand((redisContext *)c.get_raw(), cmd.__s);
    bool isNull = res == NULL;
    if(isNull){
        HXredisReply *err = new HXredisReply();
        err->error = true;
        err->str = String::create("");
        return err;
    }
    
    HXredisReply *rep = _parseReply(res, true);
    
    return rep;
}

void _freeRedisReply(::cpp::Pointer<HXredisReply> r){
}

::cpp::Pointer<HXredisReply> _getReply(::cpp::Pointer<redisContext> c){
    redisReply *res;
    int status = redisGetReply((redisContext *)c, (void **)&res);
    if(status == -1){
        HXredisReply *rep = new HXredisReply();
        rep->error = true;
        rep->str = String("Redis connection error");
        // freeReplyObject(res);
        return rep;
    }

    HXredisReply *rep = _parseReply(res, true);
    
    return rep;
}


::cpp::Pointer<redisContext> _redisConnect(String h, int p){
    return redisConnect(h.__s, p);
}

int _redisReconnect(::cpp::Pointer<redisContext> c){
    redisContext *ctx = (redisContext *)c.get_raw();
    return redisReconnect(ctx);
}

void _freeReplyObject(redisReplyPtr p){
    freeReplyObject(p);
}

::cpp::Pointer<redisReader> _redisReaderCreate(){
    return redisReaderCreate();
}

void _redisReaderFree(::cpp::Pointer<redisReader> r){
    redisReaderFree(r.get_raw());
}

void _redisReaderFeed(::cpp::Pointer<redisReader> r, const char* b, int s){
    redisReaderFeed(r.get_raw(), b, s);
}