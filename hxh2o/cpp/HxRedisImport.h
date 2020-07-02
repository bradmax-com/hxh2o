#include <hiredis.h>

typedef redisReply * redisReplyPtr;
typedef redisReplyPtr * redisReplyPtrPtr;

typedef struct HXredisReply HXredisReply;
    struct HXredisReply {
        bool error;
        int type;
        int integer;
        Float dval;
        int len;
        String str;
        String vtype;
        int elements;
        struct HXredisReply **element;
    };

HXCPP_EXTERN_CLASS_ATTRIBUTES cpp::Pointer<HXredisReply> _command(cpp::Pointer<redisContext> c, String str);
HXCPP_EXTERN_CLASS_ATTRIBUTES void _freeRedisReply(::cpp::Pointer<HXredisReply> c);
HXCPP_EXTERN_CLASS_ATTRIBUTES String _checkError(::cpp::Pointer<redisContext> c);
HXCPP_EXTERN_CLASS_ATTRIBUTES ::cpp::Pointer<HXredisReply> _getReply(::cpp::Pointer<redisContext> c);
HXCPP_EXTERN_CLASS_ATTRIBUTES ::cpp::Pointer<redisContext> _redisConnect(String h, int p);
HXCPP_EXTERN_CLASS_ATTRIBUTES int _redisReconnect(::cpp::Pointer<redisContext> c);
HXCPP_EXTERN_CLASS_ATTRIBUTES int _redisAppendCommand(cpp::Pointer<redisContext> c, String str);
HXCPP_EXTERN_CLASS_ATTRIBUTES void _freeReplyObject(redisReplyPtr p);
HXCPP_EXTERN_CLASS_ATTRIBUTES ::cpp::Pointer<redisReader> _redisReaderCreate();
HXCPP_EXTERN_CLASS_ATTRIBUTES void _redisReaderFree(::cpp::Pointer<redisReader> r);
HXCPP_EXTERN_CLASS_ATTRIBUTES void _redisReaderFeed(::cpp::Pointer<redisReader> r, const char* b, int s);