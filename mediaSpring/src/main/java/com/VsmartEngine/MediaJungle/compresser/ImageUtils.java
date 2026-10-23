package com.VsmartEngine.MediaJungle.compresser;

import java.io.ByteArrayOutputStream;
import java.util.zip.Deflater;
import java.util.zip.Inflater;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.VsmartEngine.MediaJungle.Banner.videoBannerController;

public class ImageUtils {
	private static final Logger logger = LoggerFactory.getLogger(ImageUtils.class);

	public static byte[] compressImage(byte[] data) {
        Deflater deflater = new Deflater();
        deflater.setLevel(Deflater.BEST_COMPRESSION);
        deflater.setInput(data);
        deflater.finish();

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream(data.length);
        byte[] tmp = new byte[4*1024];
        while (!deflater.finished()) {
            int size = deflater.deflate(tmp);
            outputStream.write(tmp, 0, size);
        }
        try {
            outputStream.close();
        } catch (Exception ignored) {
        	logger.error("", ignored);

        }
        return outputStream.toByteArray();
    }
	
	public static byte[] decompressImage(byte[] data) {
        Inflater inflater = new Inflater();
        inflater.setInput(data);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream(data.length);
        byte[] tmp = new byte[4*1024];
        try {
            while (!inflater.finished()) {
                int count = inflater.inflate(tmp);
                outputStream.write(tmp, 0, count);
            }
            outputStream.close();
        } catch (Exception ignored) {
        	logger.error("", ignored);
        }
        return outputStream.toByteArray();
    }
}


//package com.VsmartEngine.MediaJungle.compresser;
//
//import java.awt.Graphics2D;
//import java.awt.Image;
//import java.awt.image.BufferedImage;
//import java.io.ByteArrayInputStream;
//import java.io.ByteArrayOutputStream;
//import java.io.IOException;
//import javax.imageio.ImageIO;
//import java.util.zip.Deflater;
//import java.util.zip.Inflater;
//
//public class ImageUtils {
//
//    // Compress image using Deflater
//    public static byte[] compressImage(byte[] data) {
//        System.out.println("Original image size before compression: " + data.length + " bytes");
//        
//        Deflater deflater = new Deflater();
//        deflater.setLevel(Deflater.BEST_COMPRESSION);
//        deflater.setInput(data);
//        deflater.finish();
//
//        ByteArrayOutputStream outputStream = new ByteArrayOutputStream(data.length);
//        byte[] tmp = new byte[4 * 1024];
//        while (!deflater.finished()) {
//            int size = deflater.deflate(tmp);
//            outputStream.write(tmp, 0, size);
//        }
//        try {
//            outputStream.close();
//        } catch (IOException ignored) {
//        }
//        
//        byte[] compressedData = outputStream.toByteArray();
//        System.out.println("Compressed image size: " + compressedData.length + " bytes");
//        return compressedData;
//    }
//
//    // Decompress image using Inflater
//    public static byte[] decompressImage(byte[] data) {
//        System.out.println("Compressed image size before decompression: " + data.length + " bytes");
//        
//        Inflater inflater = new Inflater();
//        inflater.setInput(data);
//        ByteArrayOutputStream outputStream = new ByteArrayOutputStream(data.length);
//        byte[] tmp = new byte[4 * 1024];
//        try {
//            while (!inflater.finished()) {
//                int count = inflater.inflate(tmp);
//                outputStream.write(tmp, 0, count);
//            }
//            outputStream.close();
//        } catch (Exception ignored) {
//        }
//        
//        byte[] decompressedData = outputStream.toByteArray();
//        System.out.println("Decompressed image size: " + decompressedData.length + " bytes");
//        return decompressedData;
//    }
//
//    // Resize the image to reduce its size
//    public static byte[] resizeImage(byte[] originalImageData, int targetWidth, int targetHeight) throws IOException {
//        System.out.println("Original image size: " + originalImageData.length + " bytes");
//        
//        ByteArrayInputStream inputStream = new ByteArrayInputStream(originalImageData);
//        BufferedImage originalImage = ImageIO.read(inputStream);
//
//        // Create a scaled version of the image
//        Image scaledImage = originalImage.getScaledInstance(targetWidth, targetHeight, Image.SCALE_SMOOTH);
//        BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
//
//        // Draw the scaled image onto the resized image
//        Graphics2D graphics2D = resizedImage.createGraphics();
//        graphics2D.drawImage(scaledImage, 0, 0, null);
//        graphics2D.dispose();
//
//        // Convert resized BufferedImage back to byte array
//        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//        ImageIO.write(resizedImage, "jpg", outputStream); // or "png" depending on the format
//        
//        byte[] resizedImageData = outputStream.toByteArray();
//        System.out.println("Resized image size: " + resizedImageData.length + " bytes");
//        return resizedImageData;
//    }
//}

