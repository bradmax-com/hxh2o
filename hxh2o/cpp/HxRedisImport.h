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

HXCPP_EXTERN_CLASS_ATTRIBUTES ::cpp::Pointer<HXredisReply> _command(::cpp::Pointer<redisContext> c, ::String str);
HXCPP_EXTERN_CLASS_ATTRIBUTES void _HXfreeRedisReply(::cpp::Pointer<HXredisReply> c);
HXCPP_EXTERN_CLASS_ATTRIBUTES ::String _checkError(::cpp::Pointer<redisContext> c);
HXCPP_EXTERN_CLASS_ATTRIBUTES ::cpp::Pointer<HXredisReply> _getReply(::cpp::Pointer<redisContext> c);