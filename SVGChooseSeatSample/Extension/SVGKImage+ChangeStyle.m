//
//  SVGKImage+ChangeStyle.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/10/13.
//

#import "SVGKImage+ChangeStyle.h"

static NSString *svgNamespace = @"http://www.w3.org/2000/svg";

@implementation SVGKImage (ChangeStyle)

- (void)kk_internalChangeFillColorForSubElement:(__kindof SVGElement *)element fillColor:(NSString *)fillColor strokeColor:(NSString *)strokeColor {

    if ([element isKindOfClass:SVGElement.class] && [element respondsToSelector:@selector(hasAttribute:)] && [element hasAttribute:@"fill"]) {
        [element setAttributeNS:svgNamespace qualifiedName:@"fill" value:fillColor];
    }

    if (strokeColor && [element isKindOfClass:SVGElement.class] && [element respondsToSelector:@selector(hasAttribute:)] && [element hasAttribute:@"stroke"]) {
        [element setAttributeNS:svgNamespace qualifiedName:@"stroke" value:strokeColor];
    }

    if ([element hasChildNodes]) {
        for (__kindof SVGElement *subElement in element.childNodes) {
            [self kk_internalChangeFillColorForSubElement:subElement fillColor:fillColor strokeColor:strokeColor];
        }
    }
}
- (void)kk_changeFillColor:(NSString *)fillColor strokeColor:(NSString *)strokeColor {
    SVGSVGElement *DOMTree = self.DOMTree;
    [self kk_internalChangeFillColorForSubElement:DOMTree fillColor:fillColor strokeColor:strokeColor];
}
@end
