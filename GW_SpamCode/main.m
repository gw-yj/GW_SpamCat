//
//  main.m
//  generateSpamCode
//
//  Created by 柯磊 on 2017/7/5.
//  Copyright © 2017年 GAEA. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>

#pragma mark - 命令行修改工程目录下所有 png 资源 hash 值
//使用 ImageMagick 进行图片压缩，所以需要安装 ImageMagick，安装方法 brew install imagemagick
// find . -iname "*.png" -exec echo {} \; -exec convert {} {} \;
// or
// find . -iname "*.png" -eshamexec echo {} \; -exec convert {} -quality 95 {} \;

#pragma mark - 使用说明 -- 多scheme选择，每个scheme有固定的功能 -- 必传参数GW_RootDir，GW_XcodeprojName，GW_MainDirName
// 1.GW_修改项目名 需要修改参数GW_OldProjectName，GW_NewProjectName -- 注意事项，修改完以后GW_XcodeprojName，GW_MainDirName都需要修改
// 2.GW_修改特定类前缀 需要修改参数GW_OldClassNamePrefix，GW_NewClassNamePrefix（如果需要忽略某些文件夹，请配合参数GW_IgnoreDirNames使用） -- 对于不含有GW_OldClassNamePrefix前缀的类，不做修改。
// 3.GW_添加所有类前缀 需要修改参数GW_OldClassNamePrefix，GW_NewClassNamePrefix（如果需要忽略某些文件夹，请配合参数GW_IgnoreDirNames使用） -- 对于所有类统改，如果包含参数GW_OldClassNamePrefix会进行替换，如果不包含会进行前缀添加操作。
// 4.GW_生成混淆代码 需要修改参数GW_OutDirString，GW_OutParameterName，GW_SpamCodeFuncationCallName，GW_NewClassFuncationCallName（如果需要忽略某些文件夹，请配合参数GW_IgnoreDirNames使用）
// 5.GW_修改图片名称 此操作只会对原图片名称进行修改，不会对asset里面引用图片进行修改
// 6.GW_删除代码注释 此操作会将代码里面的注释全部删除 -- 请查看正则的规则是否符合你的项目，谨慎操作

//文件类型
typedef NS_ENUM(NSInteger, GW_SourceType) {
//    类
    GW_SourceTypeClass,
//    扩展
    GW_SourceTypeCategory,
};


#pragma mark - 项目根目录 -- 必传 -- 需修改
NSString *GW_RootDir = @"/Users/DoubleK/Desktop/XYWeiboCells-master/XYWeiboExample";
#pragma mark - 项目Xcodeproj名称 -- 必传 -- 需修改
NSString *GW_XcodeprojName = @"XYWeiboExample";
#pragma mark - 项目主目录文件夹名称 -- 必传 -- 需修改
NSString *GW_MainDirName = @"XYWeiboExample";

#pragma mark - 项目-原名称 -- 配合needModifyProjectName使用 -- 需修改
NSString *GW_OldProjectName = @"TongJiShi";
#pragma mark - 项目-新名称 -- 配合needModifyProjectName使用 -- 需修改
NSString *GW_NewProjectName = @"KaoYan";

#pragma mark - 类-老前缀名称 -- 配合needModifyClassNamePrefix使用 -- 需修改
NSString *GW_OldClassNamePrefix = @"XY";
#pragma mark - 类-新前缀名称 -- 配合needModifyClassNamePrefix使用 -- 需修改
NSString *GW_NewClassNamePrefix = @"JJSFind";


#pragma mark - 输出垃圾代码目录 -- 保证是一个空文件夹 -- 需修改
NSString *GW_OutDirString = @"/Users/DoubleK/Downloads/OnlineShopDemo-master/CFOnlineShop/kuozhan";
#pragma mark - 垃圾代码属性名-前缀 -- 需修改
NSString *GW_OutParameterName = @"onlineShop";
#pragma mark - 垃圾代码函数调用名-前缀 -- 需修改
NSString *GW_SpamCodeFuncationCallName = @"onlineShopO";
#pragma mark - 新函数调用名-前缀 -- 需修改
NSString *GW_NewClassFuncationCallName = @"onlineShopT";
#pragma mark - 忽略文件夹名称 -- 需修改 用，号隔开
NSString *GW_IgnoreDirNames = @"Libs(库),faces,ImageFiles,Others(其它),Storyboard";


#pragma mark - private
static NSString * const GW_SpamCodeClassDirName = @"GW_SJCode";
NSString *GW_SourceCodeDir = nil;
NSArray<NSString *> *GW_IgnoreDirNamesArr = nil;
BOOL needAddClassNamePrefix = NO;

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 公共方法

#pragma mark - 修改项目名称
void goModifyProjectName(void);
#pragma mark - 修改类前缀
void goModifyClassNamePrefix(NSString *projectFilePath);
#pragma mark - 生成垃圾代码 -- 代码规律暂时不可控 -- 暂停使用
void goSpamCodeOut(void);
#pragma mark - 修改图片名称 -- 只是修改图片的名称 -- 不会修改xcassets里面的文件引用
void goHandleXcassets(void);
#pragma mark - 删除注释
void goDeleteComments(void);


void recursiveDirectory(NSString *directory, NSArray<NSString *> *GW_IgnoreDirNames, void(^handleMFile)(NSString *mFilePath), void(^handleSwiftFile)(NSString *swiftFilePath));

void generateSpamCodeFile(NSString *outDirectory, NSString *mFilePath, GW_SourceType type, NSMutableString *categoryCallImportString, NSMutableString *categoryCallFuncString, NSMutableString *newClassCallImportString, NSMutableString *newClassCallFuncString);

void generateSwiftSpamCodeFile(NSString *outDirectory, NSString *swiftFilePath);

/**
 生成随机字符串

 @param length 长度
 @return 随机字符串
 */
NSString *randomString(NSInteger length);

/**
 修改图片名称

 @param directory 主文件夹目录路径
 */
void handleXcassetsFiles(NSString *directory);


/**
 删除注释

 @param directory 路径
 @param GW_IgnoreDirNames 忽略文件
 */
void deleteComments(NSString *directory, NSArray<NSString *> *GW_IgnoreDirNames);


/**
 修改项目名

 @param projectDir 路径
 @param oldName 老项目名称
 @param newName 新项目名称
 */
void modifyProjectName(NSString *projectDir, NSString *oldName, NSString *newName);


/**
 修改类前缀

 @param projectContent 路径
 @param sourceCodeDir 资源路径
 @param GW_IgnoreDirNames 忽略文件
 @param oldName 老前缀
 @param newName 新前缀
 */
void modifyClassNamePrefix(NSMutableString *projectContent, NSString *sourceCodeDir, NSArray<NSString *> *GW_IgnoreDirNames, NSString *oldName, NSString *newName);

//随机字符串
static const NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";


/**
 随机字符串

 @param length 字符长度
 @return 随机字符
 */
NSString *randomString(NSInteger length) {
    NSMutableString *ret = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [ret appendFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((uint32_t)[kRandomAlphabet length])]];
    }
    return ret;
}

NSString *randomLetter() {
    return [NSString stringWithFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform(52)]];
}


NSRange getOutermostCurlyBraceRange(NSString *string, unichar beginChar, unichar endChar, NSInteger beginIndex) {
    NSInteger braceCount = -1;
    NSInteger endIndex = string.length - 1;
    for (NSInteger i = beginIndex; i <= endIndex; i++) {
        unichar c = [string characterAtIndex:i];
        if (c == beginChar) {
            braceCount = ((braceCount == -1) ? 0 : braceCount) + 1;
        } else if (c == endChar) {
            braceCount--;
        }
        if (braceCount == 0) {
            endIndex = i;
            break;
        }
    }
    return NSMakeRange(beginIndex + 1, endIndex - beginIndex - 1);
}

NSString * getSwiftImportString(NSString *string) {
    NSMutableString *ret = [NSMutableString string];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *import *.+" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [string substringWithRange:obj.range];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    return ret;
}

BOOL regularReplacement(NSMutableString *originalString, NSString *regularExpression, NSString *newString) {
    __block BOOL isChanged = NO;
    BOOL isGroupNo1 = [newString isEqualToString:@"\\1"];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnixLineSeparators error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isChanged) {
            isChanged = YES;
        }
        if (isGroupNo1) {
            NSString *withString = [originalString substringWithRange:[obj rangeAtIndex:1]];
            [originalString replaceCharactersInRange:obj.range withString:withString];
        } else {
            [originalString replaceCharactersInRange:obj.range withString:newString];
        }
    }];
    return isChanged;
}

void renameFile(NSString *oldPath, NSString *newPath) {
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    if (error) {
        printf("修改文件名称失败。\n  oldPath=%s\n  newPath=%s\n  ERROR:%s\n", oldPath.UTF8String, newPath.UTF8String, error.localizedDescription.UTF8String);
        abort();
    }
}

#pragma mark - 主入口

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        GW_SourceCodeDir = [GW_RootDir stringByAppendingPathComponent:GW_XcodeprojName];
        if (GW_IgnoreDirNames && GW_IgnoreDirNames.length > 0) {
            GW_IgnoreDirNamesArr = [GW_IgnoreDirNames componentsSeparatedByString:@","];
        }
        
        needAddClassNamePrefix = NO;
        
     
#if GW_XGXMM
    goModifyProjectName();
#elif GW_XGLQZ
//        project.pbxproj项目位置
    NSString *projectFilePath = [[NSString stringWithFormat:@"%@.xcodeproj",GW_SourceCodeDir] stringByAppendingPathComponent:@"project.pbxproj"];
    goModifyClassNamePrefix(projectFilePath);
#elif GW_TJSYLQZ
    needAddClassNamePrefix = YES;
//        project.pbxproj项目位置
    NSString *projectFilePath = [[NSString stringWithFormat:@"%@.xcodeproj",GW_SourceCodeDir] stringByAppendingPathComponent:@"project.pbxproj"];
    goModifyClassNamePrefix(projectFilePath);
#elif GW_SCLJDM
    goSpamCodeOut();
#elif GW_SGTPMC
    goHandleXcassets();
#elif GW_SCDMZS
    goDeleteComments();
#endif
 
    }
    return 0;
}

#pragma mark - 修改项目名-action
void goModifyProjectName(void){
    if (GW_OldProjectName.length <= 0 || GW_NewProjectName.length <= 0) {
        printf("修改工程名参数错误。");
        return;
    }
    printf("开始修改工程名...\n");
    @autoreleasepool {
        modifyProjectName(GW_RootDir, GW_OldProjectName, GW_NewProjectName);
    }
    printf("修改工程名完成\n");
}

#pragma mark - 修改类名前缀-action
void goModifyClassNamePrefix(NSString *projectFilePath){
    BOOL isDirectory = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    GW_SourceCodeDir = [GW_RootDir stringByAppendingPathComponent:GW_MainDirName];
    if (![fm fileExistsAtPath:GW_SourceCodeDir isDirectory:&isDirectory] || !isDirectory
        || ![fm fileExistsAtPath:projectFilePath isDirectory:&isDirectory] || isDirectory) {
        printf("修改类名前缀的工程文件参数错误。%s", GW_SourceCodeDir.UTF8String);
        return;
    }
    
    if (GW_OldClassNamePrefix.length <= 0 || GW_NewClassNamePrefix.length <= 0) {
        printf("修改类名前缀参数错误。");
        return;
    }
    
    printf("开始修改类名前缀...\n");
    @autoreleasepool {
        // 打开工程文件
        NSError *error = nil;
        NSMutableString *projectContent = [NSMutableString stringWithContentsOfFile:projectFilePath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            printf("打开工程文件 %s 失败：%s\n", projectFilePath.UTF8String, error.localizedDescription.UTF8String);
            return;
        }
        
        modifyClassNamePrefix(projectContent, GW_SourceCodeDir, GW_IgnoreDirNamesArr, GW_OldClassNamePrefix, GW_NewClassNamePrefix);
        
        [projectContent writeToFile:projectFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    printf("修改类名前缀完成\n");
}

#pragma mark - 生成垃圾代码-action
void goSpamCodeOut(void){
    BOOL isDirectory = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:GW_OutDirString isDirectory:&isDirectory]) {
        if (!isDirectory) {
            printf("%s 已存在但不是文件夹，需要传入一个输出文件夹目录\n", [GW_OutDirString UTF8String]);
            return;
        }
    } else {
        NSError *error = nil;
        if (![fm createDirectoryAtPath:GW_OutDirString withIntermediateDirectories:YES attributes:nil error:&error]) {
            printf("创建输出目录失败，请确认 -spamCodeOut 之后接的是一个“输出文件夹目录”参数，错误信息如下：\n传入的输出文件夹目录：%s\n%s\n", [GW_OutDirString UTF8String], [error.localizedDescription UTF8String]);
            return;
        }
    }
    
    NSString *nClassOutDirString = [GW_OutDirString stringByAppendingPathComponent:GW_SpamCodeClassDirName];
    if ([fm fileExistsAtPath:nClassOutDirString isDirectory:&isDirectory]) {
        if (!isDirectory) {
            printf("%s 已存在但不是文件夹\n", [nClassOutDirString UTF8String]);
            return;
        }
    } else {
        NSError *error = nil;
        if (![fm createDirectoryAtPath:nClassOutDirString withIntermediateDirectories:YES attributes:nil error:&error]) {
            printf("创建输出目录 %s 失败", [nClassOutDirString UTF8String]);
            return;
        }
    }
    
    
    if (GW_OutParameterName.length > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+" options:0 error:nil];
        if ([regex numberOfMatchesInString:GW_OutParameterName options:0 range:NSMakeRange(0, GW_OutParameterName.length)] <= 0) {
            printf("缺少垃圾代码参数名，或参数名\"%s\"不合法(需要字母开头)\n", [GW_OutParameterName UTF8String]);
            return;
        }
    }
    
    if (GW_SpamCodeFuncationCallName.length > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+" options:0 error:nil];
        if ([regex numberOfMatchesInString:GW_SpamCodeFuncationCallName options:0 range:NSMakeRange(0, GW_SpamCodeFuncationCallName.length)] <= 0) {
            printf("缺少垃圾代码函数调用名，或参数名\"%s\"不合法(需要字母开头)\n", [GW_SpamCodeFuncationCallName UTF8String]);
            return;
        }
    }
    
    if (GW_NewClassFuncationCallName.length > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+" options:0 error:nil];
        if ([regex numberOfMatchesInString:GW_NewClassFuncationCallName options:0 range:NSMakeRange(0, GW_NewClassFuncationCallName.length)] <= 0) {
            printf("缺少 NewClass 代码函数调用名，或参数名\"%s\"不合法(需要字母开头)\n", [GW_NewClassFuncationCallName UTF8String]);
            return;
        }
    }
    
    printf("开始生成垃圾代码\n");
    NSMutableString *categoryCallImportString = [NSMutableString string];
    NSMutableString *categoryCallFuncString = [NSMutableString string];
    NSMutableString *newClassCallImportString = [NSMutableString string];
    NSMutableString *newClassCallFuncString = [NSMutableString string];
    GW_SourceCodeDir = [GW_RootDir stringByAppendingPathComponent:GW_MainDirName];
    recursiveDirectory(GW_SourceCodeDir, GW_IgnoreDirNamesArr, ^(NSString *mFilePath) {
        @autoreleasepool {
            generateSpamCodeFile(GW_OutDirString, mFilePath, GW_SourceTypeClass, categoryCallImportString, categoryCallFuncString, newClassCallImportString, newClassCallFuncString);
            generateSpamCodeFile(GW_OutDirString, mFilePath, GW_SourceTypeCategory, categoryCallImportString, categoryCallFuncString, newClassCallImportString, newClassCallFuncString);
        }
    }, ^(NSString *swiftFilePath) {
        @autoreleasepool {
            generateSwiftSpamCodeFile(GW_OutDirString, swiftFilePath);
        }
    });
    
    NSString *fileName = [GW_OutParameterName stringByAppendingString:@"CallHeader.h"];
    NSString *fileContent = [NSString stringWithFormat:@"%@\n%@return ret;\n}", categoryCallImportString, categoryCallFuncString];
    [fileContent writeToFile:[GW_OutDirString stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    fileName = [GW_SpamCodeClassDirName stringByAppendingString:@"CallHeader.h"];
    fileContent = [NSString stringWithFormat:@"%@\n%@return ret;\n}", newClassCallImportString, newClassCallFuncString];
    [fileContent writeToFile:[[GW_OutDirString stringByAppendingPathComponent:GW_SpamCodeClassDirName] stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    printf("生成垃圾代码完成\n");

}

#pragma mark - 修改图片名称-action
void goHandleXcassets(void){
    @autoreleasepool {
        handleXcassetsFiles([GW_RootDir stringByAppendingPathComponent:GW_MainDirName]);
    }
    printf("修改 Xcassets 中的图片名称完成\n");
}

#pragma mark - 删除注释-action
void goDeleteComments(void){
    @autoreleasepool {
        deleteComments(GW_SourceCodeDir, GW_IgnoreDirNamesArr);
    }
    printf("删除注释和空行完成\n");
}


#pragma mark - 生成垃圾代码

void recursiveDirectory(NSString *directory, NSArray<NSString *> *GW_IgnoreDirNames, void(^handleMFile)(NSString *mFilePath), void(^handleSwiftFile)(NSString *swiftFilePath)) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [directory stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            if (![GW_IgnoreDirNames containsObject:filePath]) {
                recursiveDirectory(path, nil, handleMFile, handleSwiftFile);
            }
            continue;
        }
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".h"]) {
            fileName = [fileName stringByDeletingPathExtension];
            
            NSString *mFileName = [fileName stringByAppendingPathExtension:@"m"];
            if ([files containsObject:mFileName]) {
                handleMFile([directory stringByAppendingPathComponent:mFileName]);
            }
        } else if ([fileName hasSuffix:@".swift"]) {
            handleSwiftFile([directory stringByAppendingPathComponent:fileName]);
        }
    }
}

NSString * getImportString(NSString *hFileContent, NSString *mFileContent) {
    NSMutableString *ret = [NSMutableString string];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *[@#]import *.+" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:hFileContent options:0 range:NSMakeRange(0, hFileContent.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [hFileContent substringWithRange:[obj rangeAtIndex:0]];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    matches = [expression matchesInString:mFileContent options:0 range:NSMakeRange(0, mFileContent.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [mFileContent substringWithRange:[obj rangeAtIndex:0]];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    return ret;
}

static NSString *const kHClassFileTemplate = @"\
%@\n\
@interface %@ (%@)\n\
%@\n\
@end\n";
static NSString *const kMClassFileTemplate = @"\
#import \"%@+%@.h\"\n\
@implementation %@ (%@)\n\
%@\n\
@end\n";
static NSString *const kHNewClassFileTemplate = @"\
#import <Foundation/Foundation.h>\n\
@interface %@: NSObject\n\
%@\n\
@end\n";
static NSString *const kMNewClassFileTemplate = @"\
#import \"%@.h\"\n\
@implementation %@\n\
%@\n\
@end\n";
void generateSpamCodeFile(NSString *outDirectory, NSString *mFilePath, GW_SourceType type, NSMutableString *categoryCallImportString, NSMutableString *categoryCallFuncString, NSMutableString *newClassCallImportString, NSMutableString *newClassCallFuncString) {
    NSString *mFileContent = [NSString stringWithContentsOfFile:mFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *regexStr;
    switch (type) {
        case GW_SourceTypeClass:
            regexStr = @" *@implementation +(\\w+)[^(]*\\n(?:.|\\n)+?@end";
            break;
        case GW_SourceTypeCategory:
            regexStr = @" *@implementation *(\\w+) *\\((\\w+)\\)(?:.|\\n)+?@end";
            break;
    }
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:mFileContent options:0 range:NSMakeRange(0, mFileContent.length)];
    if (matches.count <= 0) return;
    
    NSString *hFilePath = [mFilePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"h"];
    NSString *hFileContent = [NSString stringWithContentsOfFile:hFilePath encoding:NSUTF8StringEncoding error:nil];
    
    // 准备要引入的文件
    NSString *fileImportStrings = getImportString(hFileContent, mFileContent);
    
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull impResult, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *className = [mFileContent substringWithRange:[impResult rangeAtIndex:1]];
        NSString *categoryName = nil;
        NSString *newClassName = [NSString stringWithFormat:@"%@%@%@", GW_OutParameterName, className, randomLetter()];
        if (impResult.numberOfRanges >= 3) {
            categoryName = [mFileContent substringWithRange:[impResult rangeAtIndex:2]];
        }
        
        if (type == GW_SourceTypeClass) {
            // 如果该类型没有公开，只在 .m 文件中使用，则不处理
            NSString *regexStr = [NSString stringWithFormat:@"\\b%@\\b", className];
            NSRange range = [hFileContent rangeOfString:regexStr options:NSRegularExpressionSearch];
            if (range.location == NSNotFound) {
                return;
            }
        }

        // 查找方法
        NSString *implementation = [mFileContent substringWithRange:impResult.range];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *([-+])[^)]+\\)([^;{]+)" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:implementation options:0 range:NSMakeRange(0, implementation.length)];
        if (matches.count <= 0) return;
        
        // 新类 h m 垃圾文件内容
        NSMutableString *hNewClassFileMethodsString = [NSMutableString string];
        NSMutableString *mNewClassFileMethodsString = [NSMutableString string];
        
        // 生成 h m 垃圾文件内容
        NSMutableString *hFileMethodsString = [NSMutableString string];
        NSMutableString *mFileMethodsString = [NSMutableString string];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull matche, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *symbol = @"+";//[implementation substringWithRange:[matche rangeAtIndex:1]];
            NSString *methodName = [[implementation substringWithRange:[matche rangeAtIndex:2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *newClassMethodName = nil;
            NSString *methodCallName = nil;
            NSString *newClassMethodCallName = nil;
            if ([methodName containsString:@":"]) {
                // 去掉参数，生成无参数的新名称
                NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"\\b([\\w]+) *:" options:0 error:nil];
                NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:methodName options:0 range:NSMakeRange(0, methodName.length)];
                if (matches.count > 0) {
                    NSMutableString *newMethodName = [NSMutableString string];
                    NSMutableString *newClassNewMethodName = [NSMutableString string];
                    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull matche, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *str = [methodName substringWithRange:[matche rangeAtIndex:1]];
                        [newMethodName appendString:(newMethodName.length > 0 ? str.capitalizedString : str)];
                        [newClassNewMethodName appendFormat:@"%@%@", randomLetter(), str.capitalizedString];
                    }];
                    methodCallName = [NSString stringWithFormat:@"%@%@", newMethodName, GW_OutParameterName.capitalizedString];
                    [newMethodName appendFormat:@"%@:(NSInteger)%@", GW_OutParameterName.capitalizedString, GW_OutParameterName];
                    methodName = newMethodName;
                    
                    newClassMethodCallName = [NSString stringWithFormat:@"%@", newClassNewMethodName];
                    newClassMethodName = [NSString stringWithFormat:@"%@:(NSInteger)%@", newClassMethodCallName, GW_OutParameterName];
                } else {
                    methodName = [methodName stringByAppendingFormat:@" %@:(NSInteger)%@", GW_OutParameterName, GW_OutParameterName];
                }
            } else {
                newClassMethodCallName = [NSString stringWithFormat:@"%@%@", randomLetter(), methodName];
                newClassMethodName = [NSString stringWithFormat:@"%@:(NSInteger)%@", newClassMethodCallName, GW_OutParameterName];
                
                methodCallName = [NSString stringWithFormat:@"%@%@", methodName, GW_OutParameterName.capitalizedString];
                methodName = [methodName stringByAppendingFormat:@"%@:(NSInteger)%@", GW_OutParameterName.capitalizedString, GW_OutParameterName];
            }
            
            [hFileMethodsString appendFormat:@"%@ (BOOL)%@;\n", symbol, methodName];
            
            [mFileMethodsString appendFormat:@"%@ (BOOL)%@ {\n", symbol, methodName];
            [mFileMethodsString appendFormat:@"    return %@ %% %u == 0;\n", GW_OutParameterName, arc4random_uniform(50) + 1];
            [mFileMethodsString appendString:@"}\n"];
            
            if (methodCallName.length > 0) {
                if (GW_SpamCodeFuncationCallName && categoryCallFuncString.length <= 0) {
                    [categoryCallFuncString appendFormat:@"static inline NSInteger %@() {\nNSInteger ret = 0;\n", GW_SpamCodeFuncationCallName];
                }
                [categoryCallFuncString appendFormat:@"ret += [%@ %@:%u] ? 1 : 0;\n", className, methodCallName, arc4random_uniform(100)];
            }
            
            
            if (newClassMethodName.length > 0) {
                [hNewClassFileMethodsString appendFormat:@"%@ (BOOL)%@;\n", symbol, newClassMethodName];
                
                [mNewClassFileMethodsString appendFormat:@"%@ (BOOL)%@ {\n", symbol, newClassMethodName];
                [mNewClassFileMethodsString appendFormat:@"    return %@ %% %u == 0;\n", GW_OutParameterName, arc4random_uniform(50) + 1];
                [mNewClassFileMethodsString appendString:@"}\n"];
            }
            
            if (newClassMethodCallName.length > 0) {
                if (GW_NewClassFuncationCallName && newClassCallFuncString.length <= 0) {
                    [newClassCallFuncString appendFormat:@"static inline NSInteger %@() {\nNSInteger ret = 0;\n", GW_NewClassFuncationCallName];
                }
                [newClassCallFuncString appendFormat:@"ret += [%@ %@:%u] ? 1 : 0;\n", newClassName, newClassMethodCallName, arc4random_uniform(100)];
            }
        }];
        
        NSString *newCategoryName;
        switch (type) {
            case GW_SourceTypeClass:
                newCategoryName = GW_OutParameterName.capitalizedString;
                break;
            case GW_SourceTypeCategory:
                newCategoryName = [NSString stringWithFormat:@"%@%@", categoryName, GW_OutParameterName.capitalizedString];
                break;
        }
        
        // category m
        NSString *fileName = [NSString stringWithFormat:@"%@+%@.m", className, newCategoryName];
        NSString *fileContent = [NSString stringWithFormat:kMClassFileTemplate, className, newCategoryName, className, newCategoryName, mFileMethodsString];
        [fileContent writeToFile:[outDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        // category h
        fileName = [NSString stringWithFormat:@"%@+%@.h", className, newCategoryName];
        fileContent = [NSString stringWithFormat:kHClassFileTemplate, fileImportStrings, className, newCategoryName, hFileMethodsString];
        [fileContent writeToFile:[outDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [categoryCallImportString appendFormat:@"#import \"%@\"\n", fileName];
        
        // new class m
        NSString *newOutDirectory = [outDirectory stringByAppendingPathComponent:GW_SpamCodeClassDirName];
        fileName = [NSString stringWithFormat:@"%@.m", newClassName];
        fileContent = [NSString stringWithFormat:kMNewClassFileTemplate, newClassName, newClassName, mNewClassFileMethodsString];
        [fileContent writeToFile:[newOutDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        // new class h
        fileName = [NSString stringWithFormat:@"%@.h", newClassName];
        fileContent = [NSString stringWithFormat:kHNewClassFileTemplate, newClassName, hNewClassFileMethodsString];
        [fileContent writeToFile:[newOutDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [newClassCallImportString appendFormat:@"#import \"%@\"\n", fileName];
    }];
}

static NSString *const kSwiftFileTemplate = @"\
%@\n\
extension %@ {\n%@\
}\n";
static NSString *const kSwiftMethodTemplate = @"\
    func %@%@(_ %@: String%@) {\n\
        print(%@)\n\
    }\n";
void generateSwiftSpamCodeFile(NSString *outDirectory, NSString *swiftFilePath) {
    NSString *swiftFileContent = [NSString stringWithContentsOfFile:swiftFilePath encoding:NSUTF8StringEncoding error:nil];
    
    // 查找 class 声明
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@" *(class|struct) +(\\w+)[^{]+" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:swiftFileContent options:0 range:NSMakeRange(0, swiftFileContent.length)];
    if (matches.count <= 0) return;
    
    NSString *fileImportStrings = getSwiftImportString(swiftFileContent);
    __block NSInteger braceEndIndex = 0;
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull classResult, NSUInteger idx, BOOL * _Nonnull stop) {
        // 已经处理到该 range 后面去了，过掉
        NSInteger matchEndIndex = classResult.range.location + classResult.range.length;
        if (matchEndIndex < braceEndIndex) return;
        // 是 class 方法，过掉
        NSString *fullMatchString = [swiftFileContent substringWithRange:classResult.range];
        if ([fullMatchString containsString:@"("]) return;
        
        NSRange braceRange = getOutermostCurlyBraceRange(swiftFileContent, '{', '}', matchEndIndex);
        braceEndIndex = braceRange.location + braceRange.length;
        
        // 查找方法
        NSString *classContent = [swiftFileContent substringWithRange:braceRange];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"func +([^(]+)\\([^{]+" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:classContent options:0 range:NSMakeRange(0, classContent.length)];
        if (matches.count <= 0) return;
        
        NSMutableString *methodsString = [NSMutableString string];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull funcResult, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange funcNameRange = [funcResult rangeAtIndex:1];
            NSString *funcName = [classContent substringWithRange:funcNameRange];
            NSRange oldParameterRange = getOutermostCurlyBraceRange(classContent, '(', ')', funcNameRange.location + funcNameRange.length);
            NSString *oldParameterName = [classContent substringWithRange:oldParameterRange];
            oldParameterName = [oldParameterName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (oldParameterName.length > 0) {
                oldParameterName = [@", " stringByAppendingString:oldParameterName];
            }
            if (![funcName containsString:@"<"] && ![funcName containsString:@">"]) {
                funcName = [NSString stringWithFormat:@"%@%@", funcName, randomString(5)];
                [methodsString appendFormat:kSwiftMethodTemplate, funcName, GW_OutParameterName.capitalizedString, GW_OutParameterName, oldParameterName, GW_OutParameterName];
            } else {
                NSLog(@"string contains `[` or `]` bla! funcName: %@", funcName);
            }
        }];
        if (methodsString.length <= 0) return;
        
        NSString *className = [swiftFileContent substringWithRange:[classResult rangeAtIndex:2]];
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@Ext.swift", className, GW_OutParameterName.capitalizedString];
        NSString *filePath = [outDirectory stringByAppendingPathComponent:fileName];
        NSString *fileContent = @"";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
        fileContent = [fileContent stringByAppendingFormat:kSwiftFileTemplate, fileImportStrings, className, methodsString];
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
}

#pragma mark - 处理 Xcassets 中的图片文件

void handleXcassetsFiles(NSString *directory) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            handleXcassetsFiles(filePath);
            continue;
        }
        if (![fileName isEqualToString:@"Contents.json"]) continue;
        NSString *contentsDirectoryName = filePath.stringByDeletingLastPathComponent.lastPathComponent;
        if (![contentsDirectoryName hasSuffix:@".imageset"]) continue;
        
        NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (!fileContent) continue;
        
        NSMutableArray<NSString *> *processedImageFileNameArray = @[].mutableCopy;
        static NSString * const regexStr = @"\"filename\" *: *\"(.*)?\"";
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
        while (matches.count > 0) {
            NSInteger i = 0;
            NSString *imageFileName = nil;
            do {
                if (i >= matches.count) {
                    i = -1;
                    break;
                }
                imageFileName = [fileContent substringWithRange:[matches[i] rangeAtIndex:1]];
                i++;
            } while ([processedImageFileNameArray containsObject:imageFileName]);
            if (i < 0) break;
            
            NSString *imageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:imageFileName];
            if ([fm fileExistsAtPath:imageFilePath]) {
                NSString *newImageFileName = [randomString(10) stringByAppendingPathExtension:imageFileName.pathExtension];
                NSString *newImageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newImageFileName];
                while ([fm fileExistsAtPath:newImageFileName]) {
                    newImageFileName = [randomString(10) stringByAppendingPathExtension:imageFileName.pathExtension];
                    newImageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newImageFileName];
                }
                
                renameFile(imageFilePath, newImageFilePath);
                
                fileContent = [fileContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", imageFileName]
                                                                     withString:[NSString stringWithFormat:@"\"%@\"", newImageFileName]];
                [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                [processedImageFileNameArray addObject:newImageFileName];
            } else {
                [processedImageFileNameArray addObject:imageFileName];
            }
            
            matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
        }
    }
}

#pragma mark - 删除注释

void deleteComments(NSString *directory, NSArray<NSString *> *GW_IgnoreDirNames) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        if ([GW_IgnoreDirNames containsObject:fileName]) continue;
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            deleteComments(filePath, GW_IgnoreDirNames);
            continue;
        }
        if (![fileName hasSuffix:@".h"] && ![fileName hasSuffix:@".m"] && ![fileName hasSuffix:@".mm"] && ![fileName hasSuffix:@".swift"]) continue;
        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        regularReplacement(fileContent, @"([^:/])//.*",             @"\\1");
        regularReplacement(fileContent, @"^//.*",                   @"");
        regularReplacement(fileContent, @"/\\*{1,2}[\\s\\S]*?\\*/", @"");
        regularReplacement(fileContent, @"^\\s*\\n",                @"");
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

#pragma mark - 修改工程名

void resetEntitlementsFileName(NSString *projectPbxprojFilePath, NSString *oldName, NSString *newName) {
    NSString *rootPath = projectPbxprojFilePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:projectPbxprojFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = @"CODE_SIGN_ENTITLEMENTS = \"?([^\";]+)";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entitlementsPath = [fileContent substringWithRange:[obj rangeAtIndex:1]];
        NSString *entitlementsName = entitlementsPath.lastPathComponent.stringByDeletingPathExtension;
        if (![entitlementsName isEqualToString:oldName]) return;
        entitlementsPath = [rootPath stringByAppendingPathComponent:entitlementsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:entitlementsPath]) return;
        NSString *newPath = [entitlementsPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"entitlements"]];
        renameFile(entitlementsPath, newPath);
    }];
}

void resetBridgingHeaderFileName(NSString *projectPbxprojFilePath, NSString *oldName, NSString *newName) {
    NSString *rootPath = projectPbxprojFilePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:projectPbxprojFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = @"SWIFT_OBJC_BRIDGING_HEADER = \"?([^\";]+)";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entitlementsPath = [fileContent substringWithRange:[obj rangeAtIndex:1]];
        NSString *entitlementsName = entitlementsPath.lastPathComponent.stringByDeletingPathExtension;
        if (![entitlementsName isEqualToString:oldName]) return;
        entitlementsPath = [rootPath stringByAppendingPathComponent:entitlementsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:entitlementsPath]) return;
        NSString *newPath = [entitlementsPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"h"]];
        renameFile(entitlementsPath, newPath);
    }];
}

void replacePodfileContent(NSString *filePath, NSString *oldString, NSString *newString) {
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = [NSString stringWithFormat:@"target +'%@", oldString];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:[NSString stringWithFormat:@"target '%@", newString]];
    }];
    
    regularExpression = [NSString stringWithFormat:@"project +'%@.", oldString];
    expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:[NSString stringWithFormat:@"project '%@.", newString]];
    }];
    
    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void replaceProjectFileContent(NSString *filePath, NSString *oldString, NSString *newString) {
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldString];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:newString];
    }];
    
    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void modifyFilesClassName(NSString *sourceCodeDir, NSString *oldClassName, NSString *newClassName);

void modifyProjectName(NSString *projectDir, NSString *oldName, NSString *newName) {
    NSString *sourceCodeDirPath = [projectDir stringByAppendingPathComponent:oldName];
    NSString *xcodeprojFilePath = [sourceCodeDirPath stringByAppendingPathExtension:@"xcodeproj"];
    NSString *xcworkspaceFilePath = [sourceCodeDirPath stringByAppendingPathExtension:@"xcworkspace"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    // old-Swift.h > new-Swift.h
    modifyFilesClassName(projectDir, [oldName stringByAppendingString:@"-Swift.h"], [newName stringByAppendingString:@"-Swift.h"]);
    
#pragma mark - 改 Podfile 中的工程名
//    NSString *podfilePath = [projectDir stringByAppendingPathComponent:@"Podfile"];
//    if ([fm fileExistsAtPath:podfilePath isDirectory:&isDirectory] && !isDirectory) {
//        replacePodfileContent(podfilePath, oldName, newName);
//    }
    
    // 改工程文件内容
    if ([fm fileExistsAtPath:xcodeprojFilePath isDirectory:&isDirectory] && isDirectory) {
        // 替换 project.pbxproj 文件内容
        NSString *projectPbxprojFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"project.pbxproj"];
        if ([fm fileExistsAtPath:projectPbxprojFilePath]) {
            resetBridgingHeaderFileName(projectPbxprojFilePath, [oldName stringByAppendingString:@"-Bridging-Header"], [newName stringByAppendingString:@"-Bridging-Header"]);
            resetEntitlementsFileName(projectPbxprojFilePath, oldName, newName);
            replaceProjectFileContent(projectPbxprojFilePath, oldName, newName);
        }
        // 替换 project.xcworkspace/contents.xcworkspacedata 文件内容
        NSString *contentsXcworkspacedataFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"project.xcworkspace/contents.xcworkspacedata"];
        if ([fm fileExistsAtPath:contentsXcworkspacedataFilePath]) {
            replaceProjectFileContent(contentsXcworkspacedataFilePath, oldName, newName);
        }
        // xcuserdata 本地用户文件
        NSString *xcuserdataFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"xcuserdata"];
        if ([fm fileExistsAtPath:xcuserdataFilePath]) {
            [fm removeItemAtPath:xcuserdataFilePath error:nil];
        }
        // 改名工程文件
        renameFile(xcodeprojFilePath, [[projectDir stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"xcodeproj"]);
    }
    
    // 改工程组文件内容
    if ([fm fileExistsAtPath:xcworkspaceFilePath isDirectory:&isDirectory] && isDirectory) {
        // 替换 contents.xcworkspacedata 文件内容
        NSString *contentsXcworkspacedataFilePath = [xcworkspaceFilePath stringByAppendingPathComponent:@"contents.xcworkspacedata"];
        if ([fm fileExistsAtPath:contentsXcworkspacedataFilePath]) {
            replaceProjectFileContent(contentsXcworkspacedataFilePath, oldName, newName);
        }
        // xcuserdata 本地用户文件
        NSString *xcuserdataFilePath = [xcworkspaceFilePath stringByAppendingPathComponent:@"xcuserdata"];
        if ([fm fileExistsAtPath:xcuserdataFilePath]) {
            [fm removeItemAtPath:xcuserdataFilePath error:nil];
        }
        // 改名工程文件
        renameFile(xcworkspaceFilePath, [[projectDir stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"xcworkspace"]);
    }
    
    sourceCodeDirPath = [projectDir stringByAppendingPathComponent:GW_MainDirName];
    // 改源代码文件夹名称
    if ([fm fileExistsAtPath:sourceCodeDirPath isDirectory:&isDirectory] && isDirectory) {
        renameFile(sourceCodeDirPath, [projectDir stringByAppendingPathComponent:newName]);
    }
}

#pragma mark - 修改类名前缀

void modifyFilesClassName(NSString *sourceCodeDir, NSString *oldClassName, NSString *newClassName) {
    // 文件内容 Const > DDConst (h,m,swift,xib,storyboard)
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            modifyFilesClassName(path, oldClassName, newClassName);
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".h"] || [fileName hasSuffix:@".m"] || [fileName hasSuffix:@".pch"] || [fileName hasSuffix:@".swift"] || [fileName hasSuffix:@".xib"] || [fileName hasSuffix:@".storyboard"]) {
            
            NSError *error = nil;
            NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("打开文件 %s 失败：%s\n", path.UTF8String, error.localizedDescription.UTF8String);
                abort();
            }
            
            NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldClassName];
            BOOL isChanged = regularReplacement(fileContent, regularExpression, newClassName);
            if (!isChanged) continue;
            error = nil;
            [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("保存文件 %s 失败：%s\n", path.UTF8String, error.localizedDescription.UTF8String);
                abort();
            }
        }
    }
}

void modifyClassNamePrefix(NSMutableString *projectContent, NSString *sourceCodeDir, NSArray<NSString *> *GW_IgnoreDirNames, NSString *oldName, NSString *newName) {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 遍历源代码文件 h 与 m 配对，swift
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            if (![GW_IgnoreDirNames containsObject:filePath]) {
                modifyClassNamePrefix(projectContent, path, GW_IgnoreDirNames, oldName, newName);
            }
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent.stringByDeletingPathExtension;
        NSString *fileExtension = filePath.pathExtension;
        NSString *newClassName = @"";
        if ([fileName hasPrefix:oldName]) {
            newClassName = [newName stringByAppendingString:[fileName substringFromIndex:oldName.length]];
        } else {
            //处理是category的情况。当是category时，修改+号后面的类名前缀
            NSString *oldNamePlus = [NSString stringWithFormat:@"+%@",oldName];
            if ([fileName containsString:oldNamePlus]) {
                NSMutableString *fileNameStr = [[NSMutableString alloc] initWithString:fileName];
                [fileNameStr replaceCharactersInRange:[fileName rangeOfString:oldNamePlus] withString:[NSString stringWithFormat:@"+%@",newName]];
                newClassName = fileNameStr;
            }else if (needAddClassNamePrefix){
                newClassName = [newName stringByAppendingString:fileName];
            }else{
                continue;
            }
        }
        
        // 文件名 Const.ext > DDConst.ext
        if ([fileExtension isEqualToString:@"h"]) {
            NSString *mFileName = [fileName stringByAppendingPathExtension:@"m"];
            if ([files containsObject:mFileName]) {
                NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"h"];
                NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"h"];
                renameFile(oldFilePath, newFilePath);
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"m"];
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"m"];
                renameFile(oldFilePath, newFilePath);
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
                if ([fm fileExistsAtPath:oldFilePath]) {
                    newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                    renameFile(oldFilePath, newFilePath);
                }
                
                @autoreleasepool {
                    modifyFilesClassName(GW_SourceCodeDir, fileName, newClassName);
                }
            } else {
                continue;
            }
        } else if ([fileExtension isEqualToString:@"swift"]) {
            NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"swift"];
            NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"swift"];
            renameFile(oldFilePath, newFilePath);
            oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
            if ([fm fileExistsAtPath:oldFilePath]) {
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                renameFile(oldFilePath, newFilePath);
            }
            
            @autoreleasepool {
                modifyFilesClassName(GW_SourceCodeDir, fileName.stringByDeletingPathExtension, newClassName);
            }
        } else {
            continue;
        }
        
        // 修改工程文件中的文件名
        NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", fileName];
        regularReplacement(projectContent, regularExpression, newClassName);
    }
}
