import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers
guard CommandLine.arguments.count == 7 || CommandLine.arguments.count == 8 else {
 fputs("Usage: render-masks cards.json output-directory width height fps duration [x,y,w,h]\n", stderr); exit(1)
}
let input=CommandLine.arguments[1]
let root=CommandLine.arguments[2]+"/"
let width=Int(CommandLine.arguments[3])!, height=Int(CommandLine.arguments[4])!
let fps=Double(CommandLine.arguments[5])!, duration=Double(CommandLine.arguments[6])!
guard width>0 && height>0 && fps>0 && duration>0 else {fatalError("Dimensions, fps and duration must be positive")}
// Optional container (top-left pixel origin) for footage framed inside the video, e.g. letterboxed
let frameRect=CommandLine.arguments.count == 8 ? CommandLine.arguments[7].split(separator:",").map{Double($0)!} : [0,0,Double(width),Double(height)]
guard frameRect.count == 4 && frameRect[2]>0 && frameRect[3]>0 && frameRect[0]>=0 && frameRect[1]>=0 && frameRect[0]+frameRect[2]<=Double(width) && frameRect[1]+frameRect[3]<=Double(height) else {fatalError("Frame must be x,y,w,h inside the mask")}

struct Word: Decodable {let text:String; let start:Double}
struct Card: Decodable {let start:Double;let end:Double;let bigTop:Bool;let rows:[[Word]]}
let cards=try JSONDecoder().decode([Card].self,from:Data(contentsOf:URL(fileURLWithPath:input)))
try FileManager.default.createDirectory(atPath:root+"masks",withIntermediateDirectories:true)
for frame in 0..<Int(ceil(duration*fps - 0.000001)) {
 let time=Double(frame)/fps
 let ctx=CGContext(data:nil,width:width,height:height,bitsPerComponent:8,bytesPerRow:width*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue)!
 ctx.setFillColor(CGColor(gray:0,alpha:1));ctx.fill(CGRect(x:0,y:0,width:width,height:height))
 ctx.translateBy(x:CGFloat(frameRect[0]),y:CGFloat(Double(height)-frameRect[1]-frameRect[3]));ctx.scaleBy(x:CGFloat(frameRect[2])/680,y:CGFloat(frameRect[3])/454)
 if let card=cards.first(where: {time >= $0.start && time < $0.end}) {
  for (i,words) in card.rows.enumerated() {
   let text=words.map{$0.text}.joined(separator:" ")
   let attrs=[kCTFontAttributeName:CTFontCreateWithName("Impact" as CFString,100,nil),kCTForegroundColorAttributeName:CGColor(gray:1,alpha:1),kCTKernAttributeName:-1] as [CFString:Any]
   let line=CTLineCreateWithAttributedString(CFAttributedStringCreate(nil,text as CFString,attrs as CFDictionary)!)
   let bounds=CTLineGetBoundsWithOptions(line,[.useGlyphPathBounds])
   let topHeight:CGFloat=card.bigTop ? 218 : 112
   let h:CGFloat=i == 0 ? topHeight : 344-topHeight
   let y:CGFloat=i == 0 ? 409-topHeight : 45
   var shown=0
   for (n,w) in words.enumerated() {if time >= w.start {shown += w.text.utf16.count + (n == 0 ? 0:1)} else {break}}
   if shown == 0 {continue}
   ctx.saveGState();ctx.translateBy(x:68,y:y);ctx.scaleBy(x:544/bounds.width,y:h/bounds.height);ctx.translateBy(x:-bounds.minX,y:-bounds.minY)
   if shown < text.utf16.count {let edge=CTLineGetOffsetForStringIndex(line,shown,nil);ctx.clip(to:CGRect(x:bounds.minX-2,y:bounds.minY-2,width:edge-bounds.minX+2,height:bounds.height+4))}
   ctx.textPosition = .zero;CTLineDraw(line,ctx);ctx.restoreGState()
  }
 }
 let url=URL(fileURLWithPath:root+String(format:"masks/%04d.png",frame))
 let dst=CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil)!
 CGImageDestinationAddImage(dst,ctx.makeImage()!,nil);CGImageDestinationFinalize(dst)
}
